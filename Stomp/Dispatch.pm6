class Stomp::Dispatch;

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
    $key.Unlock(%request<password>);
    return { command => %request<command>, locked => $key.Locked };
}

method !Lock(%request, Stomp::Key $key) {
    $key.Lock();
    return { command => %request<command>, locked => $key.Locked };
}

method !Key(%request, Stomp::Key $key) {
    if $key.Locked {
        return { error => 'locked' };
    }
    return { command => %request<command>, key => $$key.GetKey() };
}

method !Shutdown(%request, $daemon) {
    note "received shutdown command";
    $daemon.Shutdown();
    panic("still alive after shutdown");
}
