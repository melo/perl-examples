#!/usr/bin/env perl

use strict;
use warnings;
use Benchmark qw( cmpthese timethese );

my $line = '1255947719 3a163121 897 01c633c7 2049 TCP request V3 2eff9a5e 6 getattr null 36 2';

system("ps l | egrep 'PID|$$' | grep -v egrep");


print "\nComparing split with regexp to extract data from lines:\n\n";

my @f;
my ($ts, $type, $op, $bytes);

cmpthese(0, {
    split => sub { @f = split(' ', $line) },
    regexp => sub { 
        $_ = $line;
        /^(\d+)/gc; $ts = $1;
        /(\w)\sV/gc; $type = $1;
        /\s(\d+)\s/gc; $op = $1;
        /\w\s(\d+)\s/gc; $bytes = $1;
    },
});

print "\n\nMeasuring impact of the bookkeeping:\n\n";

my (@req_ops, @res_ops);
my (%write_ops, %write_bytes, %read_ops, %read_bytes);
my ($read, $write);
($type, $op, $ts, $bytes) = (undef, undef, 1255947719, 500);

timethese(0, {
    t_and_7 => sub {
        $type = 't'; $op = '7';
        
        if ($type eq 't') {
            $req_ops[$op]++;
            if ($op == 7) {
                $write += $bytes;
                $ts -= $ts % 3600; # Normalize by the hour.
                $write_ops{$ts}++;
                $write_bytes{$ts} += $bytes;
            }
        } elsif ($type eq 'e') {
            $res_ops[$op]++;
            if ($op == 6) {
                $read += $bytes;

                $ts -= $ts % 3600; # Normalize by the hour.

                $read_ops{$ts}++;
                $read_bytes{$ts} += $bytes;
            }
        }
    },

    t_and_other => sub {
        $type = 't'; $op = '1';
        
        if ($type eq 't') {
            $req_ops[$op]++;
            if ($op == 7) {
                $write += $bytes;
                $ts -= $ts % 3600; # Normalize by the hour.
                $write_ops{$ts}++;
                $write_bytes{$ts} += $bytes;
            }
        } elsif ($type eq 'e') {
            $res_ops[$op]++;
            if ($op == 6) {
                $read += $bytes;

                $ts -= $ts % 3600; # Normalize by the hour.

                $read_ops{$ts}++;
                $read_bytes{$ts} += $bytes;
            }
        }
    },
    
    e_and_6 => sub {
        $type = 'e'; $op = '6';
        
        if ($type eq 't') {
            $req_ops[$op]++;
            if ($op == 7) {
                $write += $bytes;
                $ts -= $ts % 3600; # Normalize by the hour.
                $write_ops{$ts}++;
                $write_bytes{$ts} += $bytes;
            }
        } elsif ($type eq 'e') {
            $res_ops[$op]++;
            if ($op == 6) {
                $read += $bytes;

                $ts -= $ts % 3600; # Normalize by the hour.

                $read_ops{$ts}++;
                $read_bytes{$ts} += $bytes;
            }
        }
    },

    e_and_other => sub {
        $type = 'e'; $op = '1';
        
        if ($type eq 't') {
            $req_ops[$op]++;
            if ($op == 7) {
                $write += $bytes;
                $ts -= $ts % 3600; # Normalize by the hour.
                $write_ops{$ts}++;
                $write_bytes{$ts} += $bytes;
            }
        } elsif ($type eq 'e') {
            $res_ops[$op]++;
            if ($op == 6) {
                $read += $bytes;

                $ts -= $ts % 3600; # Normalize by the hour.

                $read_ops{$ts}++;
                $read_bytes{$ts} += $bytes;
            }
        }
    },
});

print "\n\n";
system("ps l | egrep 'PID|$$' | grep -v egrep");
