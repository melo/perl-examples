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

print "\n\nParsing nfsdstats records, performance report every "
  . ($mask + 1)
  . " lines\n";
print "\nPress Ctrl-C to stop with a final report (pid $$)\n\n";

my $buf    = '';
my $offset = 0;
my ($ts, $type, $op, $bytes);
my $t0   = my $tl = [gettimeofday];
my $rr = my $rrl = 0;

### Original script counters
my (
  $header1,     %read_ops, %write_ops, %read_bytes,
  %write_bytes, @req_ops,  @res_ops,   $date,
  $h,           $d,        $m,         $y
);
my ($read, $write, $nops) = (0, 0, 0);
my @opnames = (
  'null',   'getattr', 'setattr',  'lookup', 'access',  'ireadlink',
  'read',   'write',   'create',   'mkdir',  'symlink', 'mkdir',
  'remove', 'rmdir',   'rename',   'link',   'readdir', 'readdir+',
  'fsstat', 'fsinfo',  'pathconf', 'commit'
);

## discard first two lines
my $n;
do {
  $n = sysread(\*STDIN, $buf, $size);
  die "No lines, " unless $n > 0;
} until ($buf =~ s/^.+\n.+\n//);


while () {
  $n = sysread(\*STDIN, $buf, $size, length($buf));

  while ($buf =~ /(.+)\n/gc) {
    $lines++;
    $_ = $1;
    /^(\d+)/gc;      $ts = $1;
    /(\w)\sV/gc;     $type = $1;
    /\s(\d+)\s\w/gc; $op = $1;
    /\w\s(\d+)\s/gc; $bytes = $1;

    print "!!! Unrecognized line >>$_<<\n", next
      unless $ts && $type && $op && $bytes;

    ### do original bookkeeping
    if ($type eq 't') {
      $req_ops[$op]++;
      if ($op == 7) {
        $write += $bytes;

        $ts -= $ts % 3600;    # Normalize by the hour.

        $write_ops{$ts}++;
        $write_bytes{$ts} += $bytes;
      }
    }
    elsif ($type eq 'e') {
      $res_ops[$op]++;
      if ($op == 6) {
        $read += $bytes;

        $ts -= $ts % 3600;    # Normalize by the hour.

        $read_ops{$ts}++;
        $read_bytes{$ts} += $bytes;
      }
    }

    report() unless $lines & $mask;
  }
  last unless $n > 0;

  $buf = substr($buf, pos($buf));
  $rr += $n;
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

  my $r = $rr;
  $r -= $rrl unless $final;
  $rrl = $rr;
  $r >>= 20;

  my $l_rate = $d ? int($l / $d) : 'na';
  my $r_rate = $d ? $r / $d      : 'na';

  if ($final) {
    original_report();
    print "\n\nFINAL PERFORMANCE REPORT:\n\n";
  }

  print "elapsed $d, lines $lines, rate $l_rate lines/sec (read "
    . ($rr >> 20)
    . " MB, rate $r_rate MB/sec)\n";

  if ($final) {
    print "\n\n";
    system("ps l | egrep 'PID|$$' | grep -v egrep");
  }
}


### Rest of original script follows
sub get_date {
  my $ts = shift;
  my ($h, $d, $m, $y) = (localtime($ts))[2 .. 5];
  my $date =
      ($y + 1900)
    . ($m + 1 > 9 ? $m + 1 : '0' . ($m + 1))
    . ($d > 9     ? $d     : '0' . $d)
    . ($h > 9     ? $h     : '0' . $h);
  return $date;
}

sub original_report {
  print "\n\nNumber of NFSOps REQUESTS:\n";

  # 0..21 -> 22 opnames
  for (0 .. 21) {
    if ($req_ops[$_]) {
      print $opnames[$_], ":   \t", $req_ops[$_], "\n";
      $nops += $req_ops[$_];
    }
  }
  print "\nNumber of NFSOps RESPONSES:\n";
  foreach (0 .. 21) {
    print $opnames[$_], ":   \t", $res_ops[$_], "\n" if ($res_ops[$_]);
  }
  print "Total # of NFSOPs: \t", $nops, "\n";
  print "Data Read (Gb):   \t", sprintf("%.2f", ($read >> 20) / 1024),
    " Gb\n";
  print "Data Written (Gb):\t", sprintf("%.2f", ($write >> 20) / 1024),
    " Gb\n";
  print "Read/Write bytes ratio:\t", sprintf("%.2f", $read / $write), "x\n";
  print "Read/Write ops ratio:\t", sprintf("%.2f", $req_ops[6] / $req_ops[7]),
    "x\n\n\n";

  print "Number of Read Operations:\n";

  foreach my $key (keys %read_ops) {

    print $date, ", ", $read_ops{$key}, "\n";
  }
  print "\nNumber of Read Mbytes:\n";
  foreach my $key (keys %read_bytes) {
    print get_date($key), ", ",
      sprintf("%.2f", ($read_bytes{$key} >> 10) / 1024), "\n";
  }
  print "\nNumber of Write Operations:\n";
  foreach my $key (keys %write_ops) {
    print get_date($key), ", ", $write_ops{$key}, "\n";
  }
  print "\nNumber of Write Mbytes:\n";
  foreach my $key (keys %write_bytes) {
    print get_date($key), ", ",
      sprintf("%.2f", ($write_bytes{$key} >> 10) / 1024), "\n";
  }
  print "\n";
}
