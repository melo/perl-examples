#!/usr/bin/env perl

use strict;
use warnings;
use Time::HiRes qw( gettimeofday tv_interval );

## read from stdin a 1Mb at a time
my $size = 2 ** 20;
my $offset = 0;
my $buf;
my $t = 0;
my $c = 0;
my $lines = 0;

my $tlast = my $t0 = [gettimeofday];
my $llines = 0;

while () {
  my $n = sysread(\*STDIN, $buf, $size-$offset, $offset);

  while ($buf =~ /.*\n/cg) {
    $lines++;
  }
  last unless $n > 0;
  
  $buf = substr($buf, pos($buf));
  $offset = length($buf);
  $c++;
  $t += $n;
  
  if (($c & 0xfff) == 0) {
    my $now = [gettimeofday];
    my $d = tv_interval($tlast, $now);
    $tlast = $now;
    
    print STDERR "($d rate ".int(($lines-$llines)/$d).") l:$lines  b:$t ".int($t/(1024*1024))."Mb   last read $n, reads $c\n";
    $llines = $lines;
  }
}
my $d = tv_interval($t0);

print "lines $lines bytes $t\n";
print "Size mega ".int($t/(1024*1024))." reads $c\n";
print "Lines/sec ".int($lines/$d)." MB/sec ".int($t/$d)."\n";

# while ($buf =~ /.*\n/cg) {
#   $lines++;
# }
# last unless $n > 0;
# 
# $buf = substr($buf, pos($buf));
# $offset = length($buf);
# $c++;
# $t += $n;

# $offset = 0;
# while ($buf && ($pos = index($buf, "\n", $offset))) {
#   last if $pos == -1;
#   $lines++;
#   $offset = $pos+1;
# }
# last unless $n > 0;
# 
# $buf = substr($buf, $offset);
# $offset = length($buf);
# $c++;
# $t += $n;
