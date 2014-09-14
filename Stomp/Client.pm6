class Stomp::Client;

use Stomp::Utils;

method Command(Str $command) {
    my $response = self.Dispatch($command);
    return $response;
}

method Dispatch(Str $command) {
    given $command {
        when <lock> { self.Lock() }
        when <unlock> { self.Unlock() }
        when <key> { self.Key() }
        when <shutdown> { self.Shutdown() }
        default { self.Usage() }
    }
}

method Lock() {
    my $req = Stomp::Utils::PrepareRequest("lock");
    return Stomp::Utils::DoRequest($req);
}

method Unlock() {
    my $req = Stomp::Utils::PrepareRequest("unlock",
        password => AskPassword());
    return Stomp::Utils::DoRequest($req);
}

method Key() {
    my $req = Stomp::Utils::PrepareRequest("key");
    my $result = Stomp::Utils::DoRequest($req);
    if $result<error> :exists && $result<error> eq <locked> {
        self.Unlock();
        return self.Key();
    }
    return $result;
}

method Shutdown() {
    my $req = Stomp::Utils::PrepareRequest("shutdown");
    note "server sent shutdown command";
    my $result = Stomp::Utils::DoRequest($req, :noreply);
    note "done";
    return $result;
}
