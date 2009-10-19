#!/usr/bin/perl

#use strict;
#use warnings;
#use POSIX;
use Time::HiRes qw( gettimeofday tv_interval );


my $t = 0;
my $lines = 2;
my $tlast = my $t0 = [gettimeofday];
my $llines = 2;

my ($header1, %read_ops, %write_ops, %read_bytes, %write_bytes, @req_ops, @res_ops, $date, $h, $d, $m, $y);
my ($read, $write, $nops) = (0, 0, 0);
my @opnames = (
    'null',     'getattr',   'setattr', 'lookup',  'access',   'ireadlink', 'read',    'write', 
    'create',   'mkdir',     'symlink', 'mkdir',   'remove',   'rmdir',     'rename',  'link', 
    'readdir',  'readdir+',  'fsstat',  'fsinfo',  'pathconf', 'commit');

# discard first two lines
$header1 = <STDIN>;
$header1 = <STDIN>;

while(<STDIN>) {
    $lines++;
    $t += length($_);
    my @field = split ' ', $_;

    if ($field[6] eq 'request') {
        $req_ops[$field[9]]++;
        if ($field[9] == 7) {
            $write += $field[12];

            my $ts = substr($field[0], 0, 10);
            $ts -= $ts % 3600; # Normalize by the hour.

            $write_ops{$ts}++;
            $write_bytes{$ts} += $field[12];
        }
    } elsif ($field[6] eq 'response') {
        $res_ops[$field[9]]++;
        if ($field[9] == 6) {
            $read += $field[12];

            my $ts = substr($field[0], 0, 10);
            $ts -= $ts % 3600; # Normalize by the hour.

            $read_ops{$ts}++;
            $read_bytes{$ts} += $field[12];
        }
    }

    if (($lines & 0x7ffff) == 0) {
      my $now = [gettimeofday];
      my $d = tv_interval($tlast, $now);
      $tlast = $now;

      print STDERR "($d rate ".int(($lines-$llines)/$d).") l:$lines  b:$t ".int($t/(1024*1024))."Mb \n";
      $llines = $lines;
    }
}

print "Number of NFSOps REQUESTS:\n";
# 0..21 -> 22 opnames
for (0..21) {
    if ($req_ops[$_] != 0) {
        print $opnames[$_], ":   \t", $req_ops[$_], "\n";
        $nops += $req_ops[$_];
    }
}
print "\nNumber of NFSOps RESPONSES:\n";
foreach (0..21) {
    print $opnames[$_], ":   \t", $res_ops[$_], "\n" if ($res_ops[$_] != 0);
}
print "Total # of NFSOPs: \t", $nops, "\n";
print "Data Read (Gb):   \t", sprintf("%.2f", ($read  >> 20) / 1024), " Gb\n";
print "Data Written (Gb):\t", sprintf("%.2f", ($write >> 20) / 1024), " Gb\n";
print "Read/Write bytes ratio:\t", sprintf("%.2f", $read / $write), "x\n";
print "Read/Write ops ratio:\t", sprintf("%.2f", $req_ops[6] / $req_ops[7]), "x\n\n\n";

print "Number of Read Operations:\n";


sub get_date {
    my $ts = shift;
    my($h, $d, $m, $y) = (localtime($ts))[2..5];
    my $date = ($y + 1900) . ($m + 1 > 9 ? $m + 1 : '0' . ($m + 1)) . ($d > 9 ? $d : '0' . $d) . ($h > 9 ? $h : '0' . $h);
    return $date;
}
    

foreach my $key (keys %read_ops) {

    print $date, ", ", $read_ops{$key}, "\n";
}
print "\nNumber of Read Mbytes:\n";
foreach my $key (keys %read_bytes) {
    print get_date($key), ", ", sprintf("%.2f", ($read_bytes{$key} >> 10) / 1024), "\n";
}
print "\nNumber of Write Operations:\n";
foreach my $key (keys %write_ops) {
    print get_date($key), ", ", $write_ops{$key}, "\n";
}
print "\nNumber of Write Mbytes:\n";
foreach my $key (keys %write_bytes) {
    print get_date($key), ", ", sprintf("%.2f", ($write_bytes{$key} >> 10) / 1024), "\n";
}
print "\n";

my $d = tv_interval($t0);


print "lines $lines bytes $t\n";
print "Size mega ".int($t/(1024*1024))." reads $c\n";
print "Lines/sec ".int($lines/$d)." MB/sec ".int($t/$d/(1024*1024))."\n";
