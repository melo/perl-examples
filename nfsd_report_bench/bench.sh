#!/bin/sh

unset LANG
FILE=xx.gz

echo gzcat pipe wc
gzcat $FILE | time wc -lc

echo gzcat pipe perl_wc
gzcat $FILE | time ./wc_lines.pl

echo gzcat pipe system_perl perl_wc
gzcat $FILE | time /usr/bin/perl ./wc_lines.pl


## Source yy.gz (ls -laR)

## wc
## 194501376 lines 8757706752 bytes 133.00 real 117.65 user 3.17 sys

## perl_wc
## 194501376 lines 8757706752 bytes 119.28 real 101.47 user 4.93 sys
## 1630628 lines per second, 70MB/sec

## system_perl perl_wc
## 194501376 lines 8757706752 bytes 95.65 real 74.69 user 4.81 sys
## 2033469 lines per second, 87MB/sec


## Source xx.gz (data file)

## 12341864 lines 1073742171 bytes 14.52 real 13.74 user 0.39 sys
