#!/usr/bin/perl

use 5.010;
use strict;
use warnings FATAL => 'all';

# Turn on $OUTPUT_AUTOFLUSH
local $| = 1;

use Test::More;
use Test::Deep;
plan( tests => 2 );


#Top
use t::lib::Debugger;

start_script('t/eg/14-y_zero.pl');
my $debugger;
$debugger = start_debugger();
my $out = $debugger->get;


#Body
like( $debugger->list_subroutine_names(),         qr{Term::ReadLine}, 'S module' );
like( $debugger->list_subroutine_names('strict'), qr{strict},         'S module plus regex' );


#Tail
$debugger->quit;
done_testing();

1;

__END__
