#!/usr/bin/env perl

use strict;
use warnings;
use BSD::Resource;

sub check_resources {
  my $desc  = shift;
  my @names = qw( utime stime maxrss ixrss idrss isrss minflt majflt
    nswap inblock oublock msgsnd msgrcv nsignals nvcsw nivcsw );
  my $usage = getrusage();

  print "Resources ($desc):";
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
