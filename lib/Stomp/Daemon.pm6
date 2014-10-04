class Stomp::Daemon;

use Stomp::Config;
use Stomp::Daemon::Dispatch;
use Stomp::Key;
use Stomp::Utils;

my Str $localhost = $Stomp::Config::Host;
my Int $localport = $Stomp::Config::Port;
has IO::Socket::INET $!socket;
has Stomp::Key $.key;
has Bool $!running;

method stop-collaborate-and-listen() {
    debug("{PROGNAME()}: starting...", 1);
    $!key = Stomp::Key.new();

    $!socket = IO::Socket::INET.new(:$localhost, :$localport, :listen);
    $!running = True;
    debug("{PROGNAME()}: started", 1);

    while ($!running && my $client = $!socket.accept()) {
        my $message = $client.recv();
        my $response = Stomp::Daemon::Dispatch.command($message, self);
        $client.send($response);
        $client.close();
    }
    debug("{PROGNAME()}: stopped", 1);
}

method shutdown() {
    debug("{PROGNAME()}: stopping...", 1);
    $!key.finish($!key);
    $!running = False;
    $!socket.close();
}
