class Stomp::Daemon;

use Stomp::Config;
use Stomp::Daemon::Dispatch;
use Stomp::Key;

my Str $localhost = $Stomp::Config::Host;
my Int $localport = $Stomp::Config::Port;

has $!socket;
has Tap $!tap;

has Stomp::Key $.key;

has Bool $!running = True;

method stop-collaborate-and-listen() {
    note "$*PROGRAM_NAME: starting...";
    $!key = Stomp::Key.new();

    $!socket = IO::Socket::Async.listen($localhost, $localport);
    $!tap = $!socket.tap( -> $connection {
        $connection.chars_supply.tap( -> $message {
            my $response = Stomp::Daemon::Dispatch.Command($message, self);
            await $connection.send($response);
            $connection.close();
        });
        Thread.yield();
    });
    note "$*PROGRAM_NAME: started";
    while ($!running) {
        Thread.yield();
        sleep(1);
    }
    note "$*PROGRAM_NAME: stopped";
}

method shutdown() {
    note "$*PROGRAM_NAME: stopping...";
    $!key.finish($!key);
    $!tap.close();
    # FIXME 'Illegal attempt to pop empty temporary root stack'
    #$!Promise.keep(1);
    $!running = False;
}
