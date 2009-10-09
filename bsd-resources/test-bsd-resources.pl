#!/usr/bin/env perl

use strict;
use warnings;
use BSD::Resource;
use Time::HiRes qw( gettimeofday tv_interval );

my $t0;
my $r0;

sub check_resources {
  my $desc  = shift;
  my @names = qw( utime stime maxrss ixrss idrss isrss minflt majflt
    nswap inblock oublock msgsnd msgrcv nsignals nvcsw nivcsw );

  my $usage = getrusage();
  
  my ($dt, $dr, $t1, $r1);
  $t1 = [gettimeofday()];
  $dt = tv_interval($t0, $t1) if defined $t0;
  $t0 = $t1;
  
  $r1 = $usage->utime + $usage->stime;
  $dr = $r1 - $r0 if defined $r0;
  $r0 = $r1;

  print "\nResources";
  
  printf(', real %0.4f', $dt) if defined $dt;
  printf(', CPU %0.4f', $dr)  if defined $dr;
  printf(', usage %0.4f%%', $dr/$dt*100) if defined $dr && defined $dt;
  
  print " ($desc):\n";
  for my $name (@names) {
    my $value = $usage->$name();
    print "  $name: $value\n" if $value;
  }
  print "\n";
}


check_resources('Start');
sleep(1);
check_resources('After sleep 1');
my $c = 10_000_000;
while ($c--) { }
check_resources('After 10_000_000 iters');
sleep(1);
check_resources('Another sleep');
my $big1 = 'a' x 10_000_000;
check_resources('10Mb buffer');
my $big2 = 'a' x 30_000_000;
check_resources('30Mb buffer');
$c = 5_000_000;
while ($c--) { }
check_resources('After another 5_000_000 iters');
