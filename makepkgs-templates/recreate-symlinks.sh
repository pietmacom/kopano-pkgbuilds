#!/bin/sh -ex
_dir=$(realpath $(dirname $0))

find ${_dir} -type l -exec rm {} \;
find ${_dir} -name "*.template" -print0 | while read -d $'\0' template
do
    ln -s $template $(echo "$template" | sed 's|-[1-9?].template|.template|')
done
