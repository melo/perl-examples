#!/usr/bin/env perl

use common::sense;
use AnyEvent::Gearman;
use AnyEvent;

my $cv = AnyEvent->condvar;

my $client = gearman_client '127.0.0.1';
$client->add_task(
    'slow' => 10,
    on_complete => sub {
        my $result = $_[1];
        # ...
    },
    on_fail => sub {
        # job failed
    },
);
