use v6;
use Stomp::Daemon;

%*ENV<STOMP_QUIET> = 1;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

my $d = Stomp::Daemon.new();

spurt("t/server.pid", $*PID);

$d.stop-collaborate-and-listen();

# vim: ft=perl6
