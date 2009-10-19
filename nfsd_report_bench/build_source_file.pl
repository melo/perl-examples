#!/usr/bin/env perl

use strict;
use warnings;

my $size = shift || die "Usage: build_source_file.pl SIZE\n";

## read our sample
my $sample = do { undef $/; <DATA> };

print <<HEADER;
# Extent, type='Trace::NFS::common'
packet_at source source_port dest dest_port is_udp is_request nfs_version transaction_id op_id operation rpc_status payload_length record_id
HEADER

my $delta = length($sample);
while ($size > 0) {
  print $sample;
  $size -= $delta;
} 
## 0             1        2   3        4    6   6       7  8        9 10     11   12 13
__DATA__
1253831523212739 3a163121 790 01c633c7 2049 TCP request V3 21ff6e38 3 lookup null 56 0
1253831523212743 3a163121 790 01c633c7 2049 TCP request V3 21ff6e38 3 lookup null 56 1
1253831523212746 3a163121 897 01c633c7 2049 TCP request V3 2eff9a5e 1 getattr null 36 2
1253831523212748 3a163121 897 01c633c7 2049 TCP request V3 2eff9a5e 1 getattr null 36 3
1253831523214877 2a2622c2 2049 1a264421 790 TCP response V3 2ffdae28 3 lookup 0 216 4
1253831523214886 2a2622c2 2049 1a264421 897 TCP response V3 2ffca15e 1 getattr 0 88 5       
1253831523212739 3a163121 790 01c633c7 2049 TCP request V3 21ff6e38 7 lookup null 56 0
1253831523212743 3a163121 790 01c633c7 2049 TCP request V3 21ff6e38 7 lookup null 56 1
1253831523212746 3a163121 897 01c633c7 2049 TCP request V3 2eff9a5e 7 getattr null 36 2
1253831523212739 3a163121 790 01c633c7 2049 TCP request V3 21ff6e38 6 lookup null 56 0
1253831523212743 3a163121 790 01c633c7 2049 TCP request V3 21ff6e38 6 lookup null 56 1
1253831523212746 3a163121 897 01c633c7 2049 TCP request V3 2eff9a5e 6 getattr null 36 2
