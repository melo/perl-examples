#!/bin/sh

unset LANG
FILE=nfsd.gz

echo my_stats
gzcat $FILE | time ./my_stats_basic_optimized.pl

echo system_perl my_stats
gzcat $FILE | time /usr/bin/perl ./my_stats_basic_optimized.pl

echo base_line with system_perl
gzcat $FILE | time /usr/bin/perl ./stats_basic_optimized.pl


## source nfsd.gz

## my_stats 5.10.1
## lines 12236390 bytes 1073743047
## Size mega 1024 reads 
## Lines/sec 96588 MB/sec 8
##       126.71 real       125.07 user         0.98 sys
## 
## my_stats system_perl 5.8.8
## lines 12236390 bytes 1073743047
## Size mega 1024 reads 
## Lines/sec 95987 MB/sec 8
##       127.49 real       125.42 user         0.97 sys
## 
## base_line


## base_line with system_perl
##
## lines 12236390 bytes 1073743047
## Size mega 1024 reads 
## Lines/sec 67785 MB/sec 5948171
##      180.54 real       177.24 user         1.33 sys



##### Old line counters, for reference
##
## Source yy.gz (ls -laR)

## wc
## 194501376 lines 8757706752 bytes 133.00 real 117.65 user 3.17 sys

## perl_wc
## 194501376 lines 8757706752 bytes 119.28 real 101.47 user 4.93 sys
## 1630628 lines per second, 70MB/sec

## system_perl perl_wc
## 194501376 lines 8757706752 bytes 95.65 real 74.69 user 4.81 sys
## 2033469 lines per second, 87MB/sec
