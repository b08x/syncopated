#!/usr/bin/env bash

export timestampe=$(date +'%Y-%m-%d_%H-%M-%S')
echo $timestampe

mkdir -pv /mnt/bender/storage/backupdelta/$timestampe

rsync -r -t -v --progress --ignore-existing -u -l -b -i -s \
	--exclude=.ruby-lsp/ --exclude=.vscode/ --exclude=.git* --exclude=.svn/ --exclude=go/ \
	--exclude=.obsidian/ --exclude=*.svg --exclude=*.log --exclude=.ray-snapshots/ \
	--exclude=Ardour* --exclude=airootfs/ --exclude=Obsidian_Playground/ --exclude=.asdf/*** --exclude=.vscode-oss/ \
	--exclude=.asdf/ --exclude=.bundle/ --exclude=.cache/ --exclude=.mixxx/analysis/ --exclude=.cargo/ --exclude=.cmake/ --exclude=.config/ \
	--exclude=.gnupg/ --exclude=.grsync/ --exclude=.guake/ --exclude=.helm/ --exclude=.icons/ --exclude=.local/ \
	--exclude=.log/ --exclude=.mozilla/ --exclude=.npm/ --exclude=.pki/ --exclude=.pulsar/ --exclude=.rustup/ \
	--exclude=.texlive/ --exclude=.jekyll-cache/ --exclude=_site/ --exclude=.themes/ --exclude=.vscode-oss/ --exclude=.w3m/ --exclude=PolyGlot-3.5.1/ --exclude=.config/google-chrome/ \
	--suffix=$timestampe~ --backup-dir=/mnt/bender/storage/backupdelta/$timestampe /home/b08x/ /mnt/bender/backup/

chown -R b08x:b08x /mnt/bender/storage/backupdelta/$timestampe
