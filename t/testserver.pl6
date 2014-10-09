use v6;
use lib 't';
use STHelper;
use Stomp::Daemon;

%*ENV<STOMP_DEBUG_LEVEL> = 1;

set-config();

my $d = Stomp::Daemon.new();

spurt("t/server.pid", $*PID);

$d.stop-collaborate-and-listen();

# vim: ft=perl6
