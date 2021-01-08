#!/bin/sh -e

find . -type l -exec rm {} \;
find . -name "*.template" -print0 | while read -d $'\0' template
do
    ln -s $template ./$(echo "$template" | sed 's|-[1-9?]||')
done
