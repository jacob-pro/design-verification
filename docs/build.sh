#!/bin/bash
for i in ./*.md
do :
    pandoc $i -o "${i%.md}.pdf"
done
