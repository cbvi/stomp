class Stomp::Daemon;

use Stomp::Config;
use Stomp::Daemon::Dispatch;
use Stomp::Key;

my Str $localhost = $Stomp::Config::Host;
my Int $localport = $Stomp::Config::Port;

has $!Socket;
has Tap $!Tap;

has Stomp::Key $.Key;

has Bool $!Running = True;

method StopCollaborateAndListen() {
    note "$*PROGRAM: starting...";
    $!Key = Stomp::Key.new();

    $!Socket = IO::Socket::Async.listen($localhost, $localport);
    $!Tap = $!Socket.tap( -> $connection {
        $connection.chars_supply.tap( -> $message {
            my $response = Stomp::Daemon::Dispatch.Command($message, self);
            await $connection.send($response);
            $connection.close();
        });
        Thread.yield();
    });
    note "$*PROGRAM: started";
    while ($!Running) {
        Thread.yield();
        sleep(1);
    }
    note "$*PROGRAM: stopped";
}

method Shutdown() {
    note "$*PROGRAM: stopping...";
    $!Key.Finish($!Key);
    $!Tap.close();
    # FIXME 'Illegal attempt to pop empty temporary root stack'
    #$!Promise.keep(1);
    $!Running = False;
}
