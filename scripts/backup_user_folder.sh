#!/bin/sh

source="/Volumes/Macintosh\ HD/Users/username"
		# Replace with current username
target="/Volumes/Backup_Data/"
		# Replace with correct volume name

rsync -ahx --no-p --no-g --chmod=ugo=rwX --partial-dir=rsync-partial --delete-after --force --times --ignore-errors --timeout=30 --delete-excluded --exclude 'Library' --progress ${source} ${target}

exit 0