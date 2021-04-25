# create
mkdir -p foo/bar
touch foo/bar/baz.txt

tar cJf bar.tar.xz -C foo bar

# extract
mkdir extract-top
tar xf bar.tar.xz --strip-components=1 -C extract-top
