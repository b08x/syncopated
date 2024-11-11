#!/usr/bin/env python

import os, sys, re, math, json, pathlib as pl, functools as ft, operator as op

import yaml # pip install --user pyyaml


def flat_key(s):
	'Format key segment, removing spaces, colons and dots in an irreversible way.'
	if isinstance(s, (int, float)): s = f'%{s}'
	else: s = str(s)
	s = re.sub(r':+\s+', '-_', s)
	s = re.sub(r'\s+', '_', s)
	if s.startswith('#'): s = f'_%{s[1:]}'
	return s.replace('.', '_')

def flat_value(data):
	'Format value as a single-line string, potentially mangling it a bit.'
	if isinstance(data, str):
		if '\n' in data or ': ' in data: data = json.dumps(data)
		return data
	elif isinstance(data, bool): return str(data).lower()
	elif isinstance(data, (int, float)):
		n = len(f'{data}'.split('.')[-1]) if isinstance(data, float) else 0
		return f'{{:,.{n}f}}'.format(data).replace(',', '_')
	else: raise ValueError(data)

def yaml_flatten(data, sort=True, lines=None, prefix=None, trunc_len=100):
	if lines is None: lines = list()
	if prefix is None: prefix = list()
	recurse = ft.partial( yaml_flatten,
		sort=sort, lines=lines, trunc_len=trunc_len )
	if not data and not isinstance(data, (int, float)): # empy str/list/dict
		lines.append((prefix, ''))
	elif isinstance(data, dict):
		data = data.items()
		if sort: data = sorted(data, key=op.itemgetter(0))
		for k, v in data: recurse(v, prefix=prefix + [flat_key(k)])
	elif isinstance(data, list):
		k_fmt = f'{{:0{len(str(len(data)))}d}}'.format
		for n, v in enumerate(data): recurse(v, prefix=prefix + [k_fmt(n)])
	else:
		v = flat_value(data)
		if len(v) > trunc_len: v = v[:trunc_len] + '...'
		lines.append((prefix, v))
	return lines


def main(args=None):
	import argparse, textwrap
	dd = lambda text: (textwrap.dedent(text).strip('\n') + '\n').replace('\t', '  ')
	parser = argparse.ArgumentParser(
		formatter_class=argparse.RawTextHelpFormatter,
		description=dd('''
			Convert YAML to a flat list in "dotted-key: value" format.
			Output is intended for a human reader, and not intended to be reversible/deserializable.'''))
	parser.add_argument('path', nargs='*', help='Path to the YAML file(s) to convert.')
	parser.add_argument('-c', '--convert', action='store_true',
		help='Convert all input file(s) and create .flat files next to them.')
	parser.add_argument('-u', '--unsorted', action='store_true',
		help='Do not sort mapping keys in the output, which can produce more confusing result.')
	parser.add_argument('-t', '--trunc-values', type=int, metavar='n', default=100,
		help='Truncate values with representation longer than specified length. Default: %(default)s')
	opts = parser.parse_args(sys.argv[1:] if args is None else args)

	src_list = opts.path
	if not src_list:
		if opts.convert: parser.error('No source file path(s) specfied for -c/--convert')
		src_list = [sys.stdin]
	for src in src_list:
		if src is sys.stdin: src_str = src.read()
		else:
			src_path = pl.Path(src)
			src_str = src_path.read_text()

		res = list()
		for n, src in enumerate(yaml.safe_load_all(src_str)):
			if n: res.append('\n---\n\n')
			part = yaml_flatten(src, sort=not opts.unsorted)
			res.append('\n'.join(('.'.join(k) + ':' + (f' {v}' if v else v)) for k, v in part) + '\n')
		res = ''.join(res)

		if not opts.convert:
			sys.stdout.write(res)
			sys.stdout.flush()
		else:
			p = src_path.parent / (src_path.name.rsplit('.', 1)[0] + '.flat')
			p.write_text(res)

if __name__ == '__main__': sys.exit(main())
