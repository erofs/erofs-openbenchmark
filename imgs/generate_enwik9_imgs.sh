if [[ ! -f enwik9/enwik9 ]]; then
	mkdir -p enwik9
	[ -f enwik9/enwik9.zip ] || wget -O enwik9/enwik9.zip http://cs.fit.edu/~mmahoney/compression/enwik9.zip
	unzip enwik9/enwik9.zip -d enwik9
	rm enwik9/enwik9.zip
fi

[ -z $MKSQUASHFS ] && MKSQUASHFS='./mksquashfs'

# inode compressed
$MKSQUASHFS enwik9/enwik9 enwik9_4k.squashfs.img -comp lz4 -Xhc -b 4096 -noappend
$MKSQUASHFS enwik9/enwik9 enwik9_8k.squashfs.img -comp lz4 -Xhc -b 8192 -noappend
$MKSQUASHFS enwik9/enwik9 enwik9_16k.squashfs.img -comp lz4 -Xhc -b 16384 -noappend
$MKSQUASHFS enwik9/enwik9 enwik9_128k.squashfs.img -comp lz4 -Xhc -b 131072 -noappend

# inode uncompressed
$MKSQUASHFS enwik9/enwik9 enwik9_4k.noI.squashfs.img -comp lz4 -Xhc -b 4096 -noappend -noI
$MKSQUASHFS enwik9/enwik9 enwik9_8k.noI.squashfs.img -comp lz4 -Xhc -b 8192 -noappend -noI
$MKSQUASHFS enwik9/enwik9 enwik9_16k.noI.squashfs.img -comp lz4 -Xhc -b 16384 -noappend -noI
$MKSQUASHFS enwik9/enwik9 enwik9_128k.noI.squashfs.img -comp lz4 -Xhc -b 131072 -noappend -noI

[ -z $MKFSEROFS] && MKFSEROFS='./mkfs.erofs'
$MKFSEROFS -zlz4hc enwik9_4k.erofs.img enwik9

