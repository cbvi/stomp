class Stomp::Daemon;

use Stomp::Config;

enum Command <ADD GET FIND LIST EDIT GEN>;

has IO::Socket::INET $!Socket;
has IO::Socket::INET $!Client;

has Bool $!ExpectingData = False;
has Command $!CurrentCommand;

my $localhost = $Stomp::Config::Host;
my $localport = $Stomp::Config::Port;

method MainLoop() {
    $!Socket = IO::Socket::INET.new(:$localhost, :$localport, :listen);
    my $client = $!Socket.accept();
    $!Client = $client;
    
    loop {
        my $request = self!GetRequest($client);
        self!DoSomething($request);
    }
}

method !GetRequest(IO::Socket $client) {
    my $req = '';

    while (my $sent = $client.recv(1)) {
        if $sent ne "\n" {
            $req ~= $sent;
        }
        else {
            return $req;
        }
    }
}

method !DoSomething(Str $command) {
    given $command {
        when <ADD> {
            $!CurrentCommand = ADD;
            self!StartExpectingData();
        }
        default {
            if $!ExpectingData {
                say $command;
            }
            else {
                self!InvalidRequest("not recognised");
            }
        }
    }
}

method !StartExpectingData() {
    $!ExpectingData = True;
    $!Client.send("GOAHEAD\n");
}

method !InvalidRequest(Str $err) {
    $!Client.send("WHAT: $err\n");
}
