class Stomp::Daemon::Client;

use Stomp::Utils;

method Command(Str $command) {
    return self.Dispatch($command);
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
    my $res = Stomp::Utils::DoRequest($req);

    if $res<locked> {
        msg("Locked!");
    }
}

method Unlock() {
    my $req = Stomp::Utils::PrepareRequest("unlock",
        password => AskPassword());
    my $res = Stomp::Utils::DoRequest($req);

    if not $res<locked> {
        msg("Unlocked!");
    }
}

method Key() {
    my $req = Stomp::Utils::PrepareRequest("key");
    my $result = Stomp::Utils::DoRequest($req);
    if $result<error> :exists && $result<error> eq <locked> {
        self.Unlock();
        self.Key();
    }
    return $result;
}

method Shutdown() {
    my $req = Stomp::Utils::PrepareRequest("shutdown");
    msg("server sent shutdown command");
    my $result = Stomp::Utils::DoRequest($req, :noreply);
    msg("done");
}
