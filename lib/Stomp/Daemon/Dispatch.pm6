class Stomp::Daemon::Dispatch;

use JSON::Tiny;
use Stomp::Key;
use Stomp::Utils;

method command(Str $request, $daemon) returns Str {
    my $response = self!do-something(from-json($request), $daemon);
    return to-json($response);
}

method !do-something(%request, $d) {
    given %request<command> {
        when <unlock> {
            self!unlock(%request, $d.key);
        }
        when <lock> {
            self!lock(%request, $d.key);
        }
        when <shutdown> {
            self!shutdown(%request, $d);
        }
        when <key> {
            self!key(%request, $d.key);
        }
    }
}

method !unlock(%request, Stomp::Key $key) {
    cmd('unlock');
    $key.unlock(%request<password>);
    res('locked', $key.locked);
    CATCH {
        res('error', 'password');
        return { error => 'password' }
    };
    return { command => %request<command>, locked => $key.locked };
}

method !lock(%request, Stomp::Key $key) {
    cmd('lock');
    $key.lock();
    res('locked', $key.locked);
    return { command => %request<command>, locked => $key.locked };
}

method !key(%request, Stomp::Key $key) {
    cmd('key');
    if $key.locked {
        res('error', 'locked');
        return { error => 'locked' };
    }
    res('key', '<hidden>');

    return {
        command => %request<command>,
        key => $key.base64-key()
    };
}

method !shutdown(%request, $daemon) {
    cmd('shutdown');
    $daemon.shutdown();
    return { command => 'shutdown' };
}

sub cmd(Str $command) {
    debug("{PROGNAME()}: received $command command");
}

sub res(Str $val, $res) {
    debug("{PROGNAME()}: $val => $res");
}
