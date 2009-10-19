#!/usr/bin/env perl
    
    use strict;
    use warnings;
    
    my $size = shift || 2 ** 20; ## 1Mb default
    my $offset = 0;
    my $buf = '';
    my $lines = 0;
    
    while () {
      my $n = sysread(\*STDIN, $buf, $size, length($buf));
      
      while ($buf =~ /.+\n/gc) {
        $lines++;
      }
      last unless $n > 0;
      
      print "$lines $n\n" unless $lines & 0x1ffff;
      $buf = substr($buf, pos($buf));
    }
    print "$lines\n";