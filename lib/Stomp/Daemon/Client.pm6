class Stomp::Daemon::Client;

use Stomp::Utils;

method command(Str $command) {
    return self.dispatch($command);
}

method dispatch(Str $command) {
    given $command {
        when <lock> { self.lock() }
        when <unlock> { self.unlock() }
        when <key> { self.key() }
        when <shutdown> { self.shutdown() }
        default { self.usage() }
    }
}

method lock() {
    my $req = Stomp::Utils::prepare-request("lock");
    my $res = Stomp::Utils::do-request($req);

    if $res<locked> {
        msg("Locked!");
    }
    return $res;
}

method unlock() {
    my $req = Stomp::Utils::prepare-request("unlock",
        password => Stomp::Utils::ask-password());
    my $res = Stomp::Utils::do-request($req);

    if $res<locked> :exists && not $res<locked> {
        msg("Unlocked!");
    }
    elsif $res<error> && $res<error> eq 'password' {
        msg("Decryption failed, check your password");
    }
    return $res;
}

method key() {
    my $req = Stomp::Utils::prepare-request("key");
    my $result = Stomp::Utils::do-request($req);
    if $result<error> :exists && $result<error> eq <locked> {
        self.Unlock();
        return self.Key();
    }
    return $result;
}

method shutdown() {
    my $req = Stomp::Utils::prepare-request("shutdown");
    msg("server sent shutdown command");
    my $result = Stomp::Utils::do-request($req, :noreply);
    if $result {
        panic("received response from server after shutdown");
    }
    return $result;
}
