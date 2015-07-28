#!/bin/bash

tarball_url=https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk-2.02-src.zip
temp_dir=$(mktemp -d /tmp/compile.XXXXXXXXXX)

echo "Serving files from /tmp on $PORT"
cd /tmp
python -m SimpleHTTPServer $PORT &

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $tarball_url"
curl -L $tarball_url > t.zip
unzip t.zip 

echo "Patching GCJ to work"
cp /app/.apt/usr/bin/gcj-4.8 /app/.apt/usr/bin/gcj-4.8-orig 
sed -i.bak s/\\/usr\\/share\\/java\\/libgcj-4.8.jar/~usr\\/share\\/java\\/libgcj-4.8.jar/g /app/.apt/usr/bin/gcj-4.8
ln -s /app/.apt/usr/ ~usr

cp /app/.apt/usr/bin/../lib/gcc/x86_64-linux-gnu/4.8/ecj1 /app/.apt/usr/bin/../lib/gcc/x86_64-linux-gnu/4.8/ecj1-orig
sed -i.bak s/\\/usr\\/share\\/java/~usr\\/share\\/java/g /app/.apt/usr/bin/../lib/gcc/x86_64-linux-gnu/4.8/ecj1


echo "Compiling"
(
	cd pdftk-*
	cd pdftk
	
	sed -i.bak s/VERSUFF=-4.6/VERSUFF=-4.8/g Makefile.Debian 
	sed -i.bak s/\\/usr\\/share\\/java/~usr\\/share\\/java/g Makefile.Debian 
	export CPATH=/app/.apt/usr/include/c++/4.8:`pwd`/../java
	
	make -f Makefile.Debian 

	zip -9r $temp_dir/pdftk.zip $temp_dir/pdftk-*/pdftk
)

while true
do
	sleep 1
	echo "."
done
