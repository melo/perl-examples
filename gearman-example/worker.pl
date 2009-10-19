#!/usr/bin/env perl

use common::sense;
use AnyEvent::Gearman;
use AnyEvent;

my $worker = gearman_worker '127.0.0.1';

$worker->register_function(
  aa => sub {
    my ($job) = @_;
    my $text = $job->workload;
print "Working on JOB ".$job->unique.", handle ".$job->job_handle,"\n";
    $job->complete(uc($text));
  }
);

$worker->register_function(
  xxx => sub {
    my $job = shift;
    print STDERR "Start new slow job with ID ".$job->unique."\n";
    
    my $num = 0;
    my $timer; $timer = AnyEvent->timer( after => 1, interval => .5, cb => sub {
      $job->status($num++, 19);
      print STDERR "Sent status $num, ".($num * 10)."\n";
    });
    
    my $tdone; $tdone = AnyEvent->timer( after => 10, cb => sub {
      print STDERR "Done ".$job->unique."\n";
      $job->complete("done\n");
      undef $timer;
      undef $tdone;
    });
    
  }
);

# Loop
AnyEvent->condvar->recv;
