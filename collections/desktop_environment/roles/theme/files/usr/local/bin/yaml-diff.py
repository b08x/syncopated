#!/usr/bin/env python

import pathlib as pl, subprocess as sp, collections as cs, hashlib as hl
import os, sys, re, json, tempfile, glob

import yaml # https://pyyaml.org/


# https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124
cl = type('Colors', (object,), dict((k, f'\033[{v}') for k,v in dict(
	x='0m', lrm='1;31m', ladd='1;32m', sep='1;34m',
	asym='1;93m', err='4;31m', cap='0;34m' ).items()))

git_diff_opts = 'git --no-pager diff -a --minimal --no-index -U8'.split()
git_delta_opts = [ 'delta', '-n', '--diff-highlight', '--paging=never',
	'--file-style=omit', '--keep-plus-minus-markers', '--hunk-label=@@ ',
	'--hunk-header-decoration-style=blue ul', '--hunk-header-style=line-number' ]

def py_list_fmt(o, ind=' ', len_split=80, ind1=False):
	s, lines, line, line_len = str(o), list(), list(), 0
	if isinstance(ind, int): ind *= '\t'
	for sc in [*re.split(r'(?<=[\'"],) ', s), '']:
		if not sc or (line_len := line_len + len(sc)) > len_split:
			sl = ' '.join(line)
			if not lines:
				if ind1: sl = ind + sl
			else: sl = ind + sl
			lines.append(sl); line[:], line_len = [sc], len(sc)
		else: line.append(sc)
	return '\n'.join(lines)

err_fmt = lambda err: f'[{err.__class__.__name__}] {err}'

def p_msg(s, c=None, ln_merge=False):
	if p_msg.spaced: print()
	if c: print(getattr(cl, c), end='')
	p_msg.spaced = print(f'=== {s}')
	if not ln_merge: p_msg.spaced = True
	else: print()
	if c: print(cl.x, end='')
	sys.stdout.flush()
p_msg.spaced = True

def size_str(sz, _units=list(
		reversed(list((u, 2 ** (i * 10))
		for i, u in enumerate('BKMGT'))) )):
	for u, u1 in _units:
		if sz > u1: break
	return f'{sz / float(u1):.1f}{u}'

def data_hash(data, person=b'yamldiff', **kws):
	data_bs = json.dumps(data, sort_keys=True).encode()
	return hl.blake2s(data_bs, person=person, **kws).digest()


class PrettyYAMLDumper(yaml.dumper.SafeDumper):

	def serialize_node(self, node, parent, index):
		self.anchors[node] = self.serialized_nodes.clear()
		return super().serialize_node(node, parent, index)

	def expect_block_sequence(self):
		self.increase_indent(flow=False, indentless=False)
		self.state = self.expect_first_block_sequence_item

	def expect_block_sequence_item(self, first=False):
		if not first and isinstance(self.event, yaml.events.SequenceEndEvent):
			self.indent = self.indents.pop()
			self.state = self.states.pop()
		else:
			self.write_indent()
			self.write_indicator('-', True, indention=True)
			self.states.append(self.expect_block_sequence_item)
			self.expect_node(sequence=True)

	def check_simple_key(self):
		res = super().check_simple_key()
		self.analysis.allow_flow_plain = False
		return res

	def choose_scalar_style(self, _re1=re.compile(r':(\s|$)')):
		if self.event.style != 'plain': return super().choose_scalar_style()
		if (s := self.event.value).startswith('- ') or _re1.search(s): return "'"
		if self.analysis and not self.analysis.allow_flow_plain:
			if ' ' in s: return "'"

	def str_format(self, data):
		style = None if '\n' not in data[:-1] else '|'
		if style: data = '\n'.join(line.rstrip() for line in data.split('\n'))
		return yaml.representer.ScalarNode('tag:yaml.org,2002:str', data, style=style)

PrettyYAMLDumper.add_representer( bool,
	lambda s,o: s.represent_scalar('tag:yaml.org,2002:bool', ['no', 'yes'][o]) )
PrettyYAMLDumper.add_representer( type(None),
	lambda s,o: s.represent_scalar('tag:yaml.org,2002:null', '') )
PrettyYAMLDumper.add_representer(str, PrettyYAMLDumper.str_format)


def yaml_add_vspacing(yaml_str, split_lines=40, split_count=2):
	def _add_vspacing(lines):
		a = ind_re = ind_item = None
		blocks, item_lines = list(), list()
		for n, line in enumerate(lines):
			if ind_item is None and (m := re.match('( *)[^# ]', line)):
				ind_item = m.group(1)
				lines.append(f'{ind_item}.') # to run add_vspacing on last block
			if ind_re:
				if ind_re.match(line): continue
				if n - a > split_lines: blocks.append((a, n, _add_vspacing(lines[a:n])))
				ind_re = None
			if re.match(fr'{ind_item}\S', line): item_lines.append(n)
			if m := re.match(r'( *)\S.*:\s*$', line):
				a, ind_re = n+1, re.compile(m.group(1) + r' ')
		if split_items := len(lines) > split_lines and len(item_lines) > split_count:
			for n in item_lines: lines[n] = f'\n{lines[n]}'
		for a, b, block in reversed(blocks): lines[a:b] = block
		if ind_item is not None: lines.pop()
		if split_items: lines.append('')
		return lines
	yaml_str = '\n'.join(_add_vspacing(yaml_str.splitlines()))
	return re.sub(r'\n\n+', '\n\n', yaml_str.strip() + '\n')


def yaml_sort_lists(data):
	if isinstance(data, dict):
		for k, v in data.items(): data[k] = yaml_sort_lists(v)
	elif isinstance(data, list):
		data = sorted(
			(yaml_sort_lists(d) for d in data),
			key=lambda d: json.dumps(d, sort_keys=True) )
	return data

def yaml_dump_pretty(data):
	yaml_str = yaml.dump( data,
		Dumper=PrettyYAMLDumper, default_flow_style=False, allow_unicode=True )
	return yaml_add_vspacing(yaml_str)

def yaml_load(p_or_src, sort_lists=False):
	if hasattr(p_or_src, 'read'):
		yaml_str = p_or_src.read()
		if isinstance(yaml_str, bytes): yaml_str = yaml_str.decode()
	else: yaml_str = pl.Path(p_or_src).read_text()
	data = yaml.safe_load(yaml_str.replace(' !unsafe ', ' ')) # hack for ansible YAMLs
	if sort_lists: data = yaml_sort_lists(data)
	return data


def path_names(*paths):
	'Return short and distinct names from last path components, in the same order.'
	names, paths = cs.Counter(p.name for p in paths), list(map(str, paths))
	while True:
		name, n = names.most_common(1)[0]
		if n == 1: break
		del names[name]
		upd = sorted((
				'/'.join(filter(None, p.rsplit('/', name.count('/')+2)[1:]))
				for p in paths if p.endswith(f'/{name}') ),
			key=lambda name: name.count('/') )
		if len(upd) <= 1: raise AssertionError(name, upd)
		names.update(upd)
	return list(next(n for n in names if p == n or p.endswith(f'/{n}')) for p in paths)

def path_yaml(p, p_root=None, strict=False):
	'''Return casemapped version of path, looked up from invariable p_root dir, if used.
		yaml/yml extensions at the end are also matched interchangeably.
		strict=True allows to bypass all that logic and simply return joined path.
		In case of nx path, or any path conflicts, exact/strict path is returned.
		Same as all path casemapping, this will always have a lot of caveats.'''
	if strict: return (p_root / p) if p_root else p
	p_opts, p_strict = [p := pl.Path(p)], p
	if m := re.search(r'(?i)^(.*)(\.ya?ml)$', p.name):
		ext = (ext := m[2])[:2] + ( ext[3:]
			if len(ext) == 5 else (chr(ord(ext[1]) - 24) + ext[2:]) )
		p_opts.append(p.parent / f'{m[1]}{ext}')
	for n, p in enumerate(p_opts):
		p = ''.join( f'[{c.upper()}{c.lower()}]'
			if c.isalpha() else glob.escape(c) for c in str(p) )
		p_opts[n] = (p_root / p) if p_root else pl.Path(p)
	m = sum((glob.glob(str(p)) for p in p_opts), list())
	return ( pl.Path(m[0]) if len(m) == 1
		else (p_root / p_strict) if p_root else p_strict )


def main(argv=None):
	import argparse, textwrap
	dd = lambda text: re.sub( r' \t+', ' ',
		textwrap.dedent(text).strip('\n') + '\n' ).replace('\t', '  ')
	parser = argparse.ArgumentParser(
		formatter_class=argparse.RawTextHelpFormatter,
		usage='%(prog)s [opts] file/dir1 file/dir2',
		description=dd('''
			Convert input YAML files (or two dirs with such) to stable
				normalized/readable representation and run diff command to compare those.
			Arguments must be either directories or files, not a mismatch of the two.
			If specified paths are directories, YAML files are detected
				(matching --fn-re) and compared recursively between the two.'''),
		epilog=dd(f'''
			Options to "git diff" and "delta" tool (if used) can be controlled via env vars:

				YD_GIT_DIFF="{py_list_fmt(git_diff_opts, 5)}"
				YD_DELTA="{py_list_fmt(git_delta_opts, 5)}"

			These should contain python lists-of-strings with the cmd/args, like in defaults above.'''))

	parser.add_argument('path_a', help='Path-A to use in comparison (file or dir).')
	parser.add_argument('path_b', nargs='?', help='Path-B to use in comparison (file or dir).')

	parser.add_argument('-s', '--sort-lists', action='store_true', help=dd('''
		Sort all lists (by their json) in YAML data,
			to diff elements in those regardless of their ordering.'''))
	parser.add_argument('-n', '--limit', type=int, metavar='n', help=dd('''
		Stop after processing specified number of files with non-empty diffs.'''))

	parser.add_argument('--no-delta', action='store_true', help=dd('''
		Use "git diff ... --color" instead of "delta" formatter tool.
		Delta tool URL: https://github.com/dandavison/delta'''))
	parser.add_argument('--fn-re', metavar='regexp', default=r'(?i)\.ya?ml$', help=dd('''
		Regexp used to match filename of YAML files to process if dirs are specified.
		Default: %(default)s'''))

	parser.add_argument('-f', '--reformat', action='store_true', help=dd('''
		Instead of running diff between A/B paths, copy YAML(s) from A to B,
			normalizing format to the same "prettified" one that is used for diffs,
		Pretty-prints A file(s) to stdout, if Path-B is omitted,
			with Terminal256Formatter colors if pygments module is available.
		If A is dir, only yml/yaml files in there are processed,
			and will be put into same subdirs in B as under A, created as necessary.
		Existing B file(s) will be replaced (only ones that are under A, is it's a dir).'''))
	parser.add_argument('--strict-names', action='store_true', help=dd('''
		Do not treat filenames with different capitalization and
			yml/yaml extension differences as a same file between src/dst dirs.
		Default is to normalize all that out for convenience.'''))
	parser.add_argument('-C', '--no-color', action='store_true', help=dd('''
		Disable colors. Implies --no-delta - using "git diff"
			(with colors disabled via env) instead of "delta" tool.
		Setting NO_COLOR env variable has the same effect.'''))

	opts = parser.parse_args()

	if os.environ.get('NO_COLOR'): opts.no_color = True

	p_a, p_b = (pl.Path(p) for p in [opts.path_a, opts.path_b or opts.path_a])
	if not p_a.exists(): parser.error(f'Path-A does not exists: {p_a}')
	if not (refmt := opts.reformat):
		if not opts.path_b: parser.error('Both A and B paths must be specified for diff')
		if str(p_a) == str(p_b): parser.error('Specified A/B paths are exactly same')
		if not p_b.exists(): parser.error(f'Path-B does not exists: {p_b}')
		if p_a.is_file() ^ p_b.is_file(): parser.error(f'Path file/dir types mismatch')
	elif p_a.is_dir(): p_b.mkdir(exist_ok=True)

	global cl
	git_diff, git_delta = git_diff_opts.copy(), git_delta_opts.copy()
	if any([
			git_diff_env := os.environ.get('YD_GIT_DIFF'),
			git_delta_env := os.environ.get('YD_GIT_DELTA') ]):
		import ast
		if git_diff_env: git_diff = list(ast.literal_eval(git_diff_env))
		if git_delta_env: git_delta = list(ast.literal_eval(git_delta_env))
	if opts.no_color:
		git_delta.clear()
		cl = type('NoColors', (object,), dict((k, '') for k in cl.__dict__ if k[0] != '_'))
		os.environ['GIT_CONFIG_COUNT'] = '1'
		os.environ['GIT_CONFIG_KEY_0'] = 'color.diff'
		os.environ['GIT_CONFIG_VALUE_0'] = 'never'
	elif opts.no_delta:
		git_delta.clear()
		git_diff.append('--color')


	### Build a list of diff_pairs to compare

	diff_pairs, diff_info = list(), cs.namedtuple('DiffInfo', 'name p')
	pn_a, pn_b = path_names(p_a, p_b) if p_a != p_b else (p_a.name, p_b.name)
	if p_a.is_file(): diff_pairs.append((diff_info(pn_a, p_a), diff_info(pn_b, p_b)))
	else:
		diff_names, yaml_re = set(), re.compile(opts.fn_re)
		for root, dirs, files in os.walk(p_a):
			for fn in files:
				if not yaml_re.search(fn): continue
				name_a = str((p_sa := pl.Path(root) / fn).relative_to(p_a))
				p_sb = path_yaml(name_a, p_b, opts.strict_names)
				if not p_sb.exists() and not refmt: p_sb = None
				name_b = name_a if not p_sb else str(p_sb.relative_to(p_b))
				diff_pairs.append((
					diff_info(f'a/{name_a}', p_sa),
					p_sb and diff_info(f'b/{name_b}', p_sb) ))
				diff_names.add(name_b)
		for root, dirs, files in os.walk(p_b):
			for fn in files:
				if not yaml_re.search(fn): continue
				name = str((p_sb := pl.Path(root) / fn).relative_to(p_b))
				if name in diff_names: continue
				diff_pairs.append((None, diff_info(f'b/{name}', p_sb)))
	diff_pairs.sort(key=lambda ab: (
		str(ab[0] and ab[0].p or ''), str(ab[1] and ab[1].p or '') ))


	### Reformat mode - print or create/replace files under B and exit

	if refmt:
		if (to_stdout := p_a == p_b) and not opts.no_color:
			try: import pygments, pygments.lexers, pygments.formatters
			except ImportError: pygments = None # pygments module unavailable
		for a, b in diff_pairs:
			if not a: continue
			if not to_stdout: b.p.parent.mkdir(parents=True, exist_ok=True)
			data = yaml_dump_pretty(yaml_load(a.p, opts.sort_lists))
			if to_stdout:
				if len(diff_pairs) > 1:
					p_msg(f'File {a.name.removeprefix("a/")} [ {a.p} ]', 'cap', True)
				if pygments:
					data = pygments.highlight(
						data, pygments.lexers.YamlLexer(),
						pygments.formatters.Terminal256Formatter() )
				print(data)
			else: b.p.write_text(data)
		return


	### Load and dump YAMLs to /tmp, run git-diff/delta on those

	p_msg( '---------- Diff Start ----------\n'
		+ f'=== Path-A: {pn_a}\n' + f'=== Path-B: {pn_b}', 'cap' )
	diff_n, diff_n_max = 0, max(0, opts.limit or 0)
	diff_n_done = lambda: diff_n_max and diff_n >= diff_n_max

	with tempfile.TemporaryDirectory(prefix=f'yaml-diff.{os.getpid()}.') as tmp_dir:
		tmp_dir = pl.Path(tmp_dir)
		for a, b in diff_pairs:
			diff_n += 1
			if not a: p_msg(f'Only in Path-B [ {pn_b} ]: {b.name}', 'asym', True)
			if not b: p_msg(f'Only in Path-A [ {pn_a} ]: {a.name}', 'asym', True)
			if not (a and b): continue

			## Create pretty/normalized YAML files
			ab = list()
			for pn, pi in zip('AB', [a, b]):
				(p := tmp_dir / pi.name).parent.mkdir(parents=True, exist_ok=True)
				try:
					with pi.p.open() as src:
						sz = size_str(os.fstat(src.fileno()).st_size)
						sz_lines = len(list(src))
						src.seek(0); data = yaml_load(src, opts.sort_lists)
				except Exception as err:
					p_msg(
						f'Path-{pn} comparison fail-skip: {pi.name}\n'
						f'ERROR [ {pi.p} ]: {err_fmt(err)}', 'err', True )
					break
				p.write_text(yaml_dump_pretty(data))
				ab.append((p, sz, sz_lines, data_hash(data)))
			if len(ab) != 2:
				if diff_n_done(): break
				continue # fail-skip

			## Run git-diff/delta
			(p1, sz1, sz_lines1, dh1), (p2, sz2, sz_lines2, dh2) = ab
			if dh1 == dh2: continue
			p_msg('-'*30 + ' YAML File Diff ' + '-'*30, 'sep')
			print(f'\n{cl.lrm}--- {a.name} [ {sz_lines1:,d} lines / {sz1} ]', flush=True)
			print(f'{cl.ladd}+++ {b.name} [ {sz_lines2:,d} lines / {sz2} ]', flush=True)
			if git_delta:
				sp_diff = sp.Popen(git_diff + ['--', p1, p2], stdout=sp.PIPE)
				sp.run(git_delta, stdin=sp_diff.stdout)
				sp_diff.wait()
			else: sp.run(git_diff + ['--', p1, p2])
			if diff_n_done(): break

	msg = 'Diff End' if not diff_n_done() else f'Diff Stop (diff-limit={diff_n})'
	p_msg(f'---------- {msg} ----------', 'cap')

if __name__ == '__main__':
	try: sys.exit(main())
	except BrokenPipeError: # stdout pipe closed
		os.dup2(os.open(os.devnull, os.O_WRONLY), sys.stdout.fileno())
		sys.exit(1)
