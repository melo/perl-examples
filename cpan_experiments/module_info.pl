#!/usr/bin/env perl

use strict;
use warnings;
use CPAN;

usage() unless @ARGV;

my $cpan = startup_cpan();

for my $module (@ARGV) {
  my $obj = $cpan->instance('CPAN::Module', $module);
  print "$obj->{ID} = $obj->{RO}{CPAN_VERSION}\n";
}

sub usage {
  die "Usage: $0 module ...\n";
}

sub startup_cpan {
  my $cpan = CPAN->new;
  $CPAN::Frontend = 'MyCPAN::Shell'; ## Hide output
  
  return $cpan;
}

package MyCPAN::Shell;

use parent 'CPAN::Shell';

sub print_ornamented {
  return;
}

1;
