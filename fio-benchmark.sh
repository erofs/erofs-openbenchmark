#!/bin/bash

if [ -z $2 ]; then
	echo Need a blockdevice to benchmark
	exit
fi

rounds=5
mkdir -p mntdir

for img in $(find imgs -type f -name $1\*img); do
	[ "${img/squashfs/x}" == $img ] || fs_type="squashfs"
	[ "${img/erofs/x}" == $img ] || fs_type="erofs"
	[ "${img/ext4/x}" == $img ] || fs_type="ext4"

	echo benchmarking $img with $fs_type
	dd if=$img of=$2 bs=1048576 > /dev/null 2>&1

	umount mntdir 2>/dev/null || umount -l mntdir 2>/dev/null

	[ $fs_type == "erofs" ] && mount -t erofs $2 mntdir
	[ $fs_type == "squashfs" ] && mount -t squashfs $2 mntdir
	[ $fs_type == "ext4" ] && mount -t ext4 -o ro $2 mntdir

	for i in $(find mntdir -type f); do
		echo $i
		# seq read
		if [ -z $3 -o $3 == 'seq' ]; then
			round=0
			echo "[seqread]"
			while [ $round -lt $rounds ]; do
				echo 3 > /proc/sys/vm/drop_caches; sleep 0;
				fio -filename=$i -rw=read -bs=4k -name=seqbench | grep READ
				echo 3 > /proc/sys/vm/drop_caches
				sleep 1
				round=$((round+1))
			done
		fi

		# randread
		if [ -z $3 -o $3 == 'rand' ]; then
			echo "[randread]"
			round=0
			while [ $round -lt $rounds ]; do
				echo 3 > /proc/sys/vm/drop_caches; sleep 0;
				fio -filename=$i -rw=randread -bs=4k -name=randbench | grep READ
				echo 3 > /proc/sys/vm/drop_caches
				sleep 1
				round=$((round+1))
			done
		fi

		# randread_9m (< 1/100 size of enwik9, 954MiB)
		if [ -z $3 -o $3 == 'rand9m' ]; then
			echo "[randread_9m]"
			round=0
			while [ $round -lt $rounds ]; do
				echo 3 > /proc/sys/vm/drop_caches; sleep 0;
				fio -filename=$i -rw=randread -bs=4k --io_size=9m -name=rand9mbench | grep READ
				echo 3 > /proc/sys/vm/drop_caches
				sleep 1
				round=$((round+1))
			done
		fi
	done
done

