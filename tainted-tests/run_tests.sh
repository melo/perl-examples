#!/bin/sh

PERL5LIB=./extralib:$PERL5LIB
export PERL5LIB

prove -l $@

diff -u t/tainted.t t/not_tainted.t
