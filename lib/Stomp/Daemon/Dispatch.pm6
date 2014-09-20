class Stomp::Daemon::Dispatch;

use JSON::Tiny;
use Stomp::Utils;
use Stomp::Key;

method Command(Str $request, $daemon) returns Str {
    my $response = self!DoSomething(from-json($request), $daemon);
    return to-json($response);
}

method !DoSomething(%request, $d) {
    given %request<command> {
        when <unlock> {
            self!Unlock(%request, $d.Key);
        }
        when <lock> {
            self!Lock(%request, $d.Key);
        }
        when <shutdown> {
            self!Shutdown(%request, $d);
        }
        when <key> {
            self!Key(%request, $d.Key);
        }
    }
}

method !Unlock(%request, Stomp::Key $key) {
    cmd('unlock');
    $key.Unlock(%request<password>);
    res('locked', $key.Locked);
    CATCH {
        res('error', 'password');
        return { error => 'password' }
    };
    return { command => %request<command>, locked => $key.Locked };
}

method !Lock(%request, Stomp::Key $key) {
    cmd('lock');
    $key.Lock();
    res('locked', $key.Locked);
    return { command => %request<command>, locked => $key.Locked };
}

method !Key(%request, Stomp::Key $key) {
    cmd('key');
    if $key.Locked {
        res('error', 'locked');
        return { error => 'locked' };
    }
    res('key', '<hidden>');

    return {
        command => %request<command>,
        key => Stomp::Utils::Base64Encode($key.Key())
    };
}

method !Shutdown(%request, $daemon) {
    cmd('shutdown');
    $daemon.Shutdown();
    return { command => 'shutdown' };
}

sub cmd(Str $command) {
    note "$*PROGRAM_NAME: received $command command";
}

sub res(Str $val, $res) {
    note "$*PROGRAM_NAME: $val => $res";
}
