class Stomp::Daemon;

use Stomp::Config;
use Stomp::Dispatch;
use Stomp::Key;

my Str $localhost = $Stomp::Config::Host;
my Int $localport = $Stomp::Config::Port;

has $!Socket;
has Promise $!Promise;
has Tap $!Tap;

has Stomp::Key $.Key;

method StopCollaborateAndListen() {
    note "$*PROGRAM: starting...";
    $!Key = Stomp::Key.new();

    $!Promise = Promise.new();
    $!Socket = IO::Socket::Async.listen($localhost, $localport);
    $!Tap = $!Socket.tap( -> $connection {
        $connection.chars_supply.tap( -> $message {
            my $response = Stomp::Dispatch.Command($message, self);
            await $connection.send($response);
            $connection.close();
        });
        Thread.yield();
    });
    Thread.yield();
    note "$*PROGRAM: started";
    await $!Promise;
}

method Shutdown() {
    note "$*PROGRAM: stopping...";
    $!Key.Finish($!Key);
    $!Tap.close();
    $!Promise.keep(1);
    note "$*PROGRAM: stopped";
    sleep(2);
    exit(0);
}
