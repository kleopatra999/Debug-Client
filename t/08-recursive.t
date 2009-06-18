use strict;
use warnings;

use t::lib::Debugger;

my $pid = start_script('t/eg/04-fib.pl');

require Test::More;
import Test::More;
require Test::Deep;
import Test::Deep;
my $D = re('\d+');

plan(tests => 8);

my $debugger = start_debugger();

{
    my $out = $debugger->get;
 
# Loading DB routines from perl5db.pl version 1.28
# Editor support available.
# 
# Enter h or `h h' for help, or `man perldebug' for more help.
# 
# main::(t/eg/01-add.pl:4):	$| = 1;
#   DB<1> 

    like($out, qr/Loading DB routines from perl5db.pl version/, 'loading line');
    like($out, qr{main::\(t/eg/04-fib.pl:4\):\s*\$\| = 1;}, 'line 4');
}

{
    my @out = $debugger->step_in;
    cmp_deeply(\@out, ['main::', 't/eg/04-fib.pl', 22, 'my $res = fib(10);', $D], 'line 22')
        or diag($debugger->buffer);
}

{
    my @out = $debugger->set_breakpoint('t/eg/04-fib.pl', 'fibx');
    cmp_deeply(\@out, ['', $D], 'set_breakpoint')
        or diag($debugger->buffer);
}

{
    my @out = $debugger->run;
    cmp_deeply(\@out, ['main::fibx', 't/eg/04-fib.pl', 17, '    my $n = shift;', $D], 'line 17')
        or diag($debugger->buffer);
}

{
    my @out = $debugger->get_stack_trace;
    my $trace = q($ = main::fibx(9) called from file `t/eg/04-fib.pl' line 12
$ = main::fib(10) called from file `t/eg/04-fib.pl' line 22);

    cmp_deeply(\@out, [$trace, $D], 'stack trace')
        or diag($debugger->buffer);
}

{
    my @out = $debugger->run(10);
    cmp_deeply(\@out, ['main::fib', 't/eg/04-fib.pl', 10, '    return 0 if $n == 0;', $D], 'line 10')
        or diag($debugger->buffer);
}

{
    my @out = $debugger->get_stack_trace;
    my $trace = q($ = main::fib(9) called from file `t/eg/04-fib.pl' line 18
$ = main::fibx(9) called from file `t/eg/04-fib.pl' line 12
$ = main::fib(10) called from file `t/eg/04-fib.pl' line 22);

    cmp_deeply(\@out, [$trace, $D], 'stack trace')
        or diag($debugger->buffer);
}