#!/bin/bash

mogrify -format jpg *.tif;

cp *.jpg ../thumbs;
mv *.jpg ../access;

cd ../thumbs;
mogrify -resize 200x *.jpg;