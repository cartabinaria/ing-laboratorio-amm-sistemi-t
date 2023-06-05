#!/bin/bash
# $1 nome directory
# $2.. estensioni
# $# = n. di argomenti

if test ! -d "$1" ; then
       echo "$1"' is not a valid directory' ; exit 1
fi

DIR=$1
echo "dir: $DIR"

EST="*\.+($2"

#echo "est: $EST"
shift
shift

for E in "$@" ; do
	EST=$EST"|$E" ; #echo "regex: $EST"
done
EST=$EST')$'
echo "regex final: $EST"
ls -R $DIR 2>/dev/null | egrep $EST| rev | cut -f1 -d. | rev | sort | uniq -c | sort -nr | less
