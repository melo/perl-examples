#!/usr/bin/env perl

use strict;
use warnings;

## read from stdin a 1Mb at a time
my $size = 2 ** 20;
my $buf = '' x $size;
my $t = 0;
my $c = 0;
while (my $n = sysread(\*STDIN, $buf, $size)) {
  $c++;
  $t += $n;
  print STDERR "$t ".$t/(1024*1024)." $n $c\n" if ($c & 0xfff) == 0;
} 

print "$t ".$t/(1024*1024)." ($c)\n";