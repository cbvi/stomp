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
    info('unlock');
    $key.Unlock(%request<password>);
    return { command => %request<command>, locked => $key.Locked };
}

method !Lock(%request, Stomp::Key $key) {
    info('lock');
    $key.Lock();
    return { command => %request<command>, locked => $key.Locked };
}

method !Key(%request, Stomp::Key $key) {
    info('key');
    if $key.Locked {
        return { error => 'locked' };
    }
    return { command => %request<command>, key => $key.Key() };
}

method !Shutdown(%request, $daemon) {
    info('shutdown');
    $daemon.Shutdown();
    panic("still alive after shutdown");
}

sub info(Str $command) {
    note "$*PROGRAM: received $command command";
}
