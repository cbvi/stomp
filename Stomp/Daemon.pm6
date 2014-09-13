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
    await $!Promise;
}

method Shutdown() {
    $!Key.Finish($!Key);
    $!Tap.close();
    $!Promise.keep(1);
}
