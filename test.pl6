use v6;
use lib '.';
use Stomp::Key;
use Stomp::Data;

use Stomp::Daemon;

my $x = Stomp::Daemon.new();

$x.MainLoop();
