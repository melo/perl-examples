#!/usr/bin/env perl

use strict;
use warnings;
use Time::HiRes qw( gettimeofday tv_interval );

my $mask = shift || 18;       ## report every 256k lines
my $size = shift || 2**20;    ## 1Mb default
$mask = 2**$mask - 1;

my $lines = my $ll = 0;

$SIG{INT} = sub {
  report(1);
  exit;
};

system("ps l | egrep 'PID|$$' | grep -v egrep");

print "\n\nReading line, performance report every "
  . ($mask + 1)
  . " lines\n";
print "\nPress Ctrl-C to stop with a final report (pid $$)\n\n";

my $buf    = '';
my $offset = 0;
my ($ts, $type, $op, $bytes);
my $t0   = my $tl = [gettimeofday];
my $read = my $rr = 0;
while () {
  my $n = sysread(\*STDIN, $buf, $size, length($buf));

  while ($buf =~ /(.+)\n/gc) {
    $lines++;
    $_ = $1;
    /^(\d+)/gc;      $ts = $1;
    /(\w)\sV/gc;     $type = $1;
    /\s(\d+)\s\w/gc; $op = $1;
    /\w\s(\d+)\s/gc; $bytes = $1;

    report() unless $lines & $mask;
  }
  last unless $n > 0;

  $buf = substr($buf, pos($buf));
  $read += $n;
}

report(1);

sub report {
  my ($final) = @_;

  my $now = [gettimeofday];
  my $d = tv_interval(($final ? $t0 : $tl), $now);
  $tl = $now;

  my $l = $lines;
  $l -= $ll unless $final;
  $ll = $lines;

  my $r = $read;
  $r -= $rr unless $final;
  $rr = $read;
  $r >>= 20;

  my $l_rate = $d ? int($l / $d) : 'n/a';
  my $r_rate = $d ? $r / $d      : 'n/a';

  print "\n\nFINAL REPORT:\n\n" if $final;
  print "elapsed $d, lines $lines, rate $l_rate lines/sec (read "
    . ($read >> 20)
    . " MB, rate $r_rate MB/sec)\n";

  if ($final) {
    print "\n\n";
    system("ps l | egrep 'PID|$$' | grep -v egrep");
  }
}

