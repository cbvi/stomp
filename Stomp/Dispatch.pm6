class Stomp::Dispatch;

use JSON::Tiny;
use Stomp::Data;
use Stomp::Key;

method Command(Str $message, $daemon) returns Str {
    my ($command, $data) = $message.split(' ', 2);
    return self!DoSomething($command, from-json($data), $daemon);
}

method !DoSomething(Str $command, %data, $d) {
    given $command {
        when <ADD> {
            self!Add(%data, $d.Key);
        }
        when <GET> {
            self!Get(%data, $d.Key);
        }
        when <FIND> {
            self!Find(%data, $d.Key);
        }
        when <LIST> {
            self!List($d.Key);
        }
        when <EDIT> {
            self!Edit(%data, $d.Key);
        }
        when <GEN> {
            self!Gen(%data, $d.Key);
        }
        when <SERVER> {
            self!Server(%data, $d);
        }
        default {
            return "invalid command: '$command'";
        }
    }
}

method !Add(%data, Stomp::Key $key) {
    Stomp::Data::AddData($key, %data<sitename>, %data<username>, %data<password>);
    return 'FIXME';
}

method !Get(%data, Stomp::Key $key) {
    my $result = Stomp::Data::GetData($key, %data<sitename>);
    return to-json($result);
}

method !Find(%data, Stomp::Key $key) {
    my $result = Stomp::Data::FindData($key, %data<searchterm>);
    return to-json($result);
}

method !List(Stomp::Key $key) {
    my $result = Stomp::Data::ListData($key);
    return to-json($result);
}

method !Edit(%data, Stomp::Key $key) {
    Stomp::Data::EditData($key, %data<sitename>, %data);
    return "FIX ME";
}

method !Gen(%data, Stomp::Key $key) {
    return "FIX ME";
}

method !Server(%data, $daemon) {
    my Str $r = 'SERVER: invalid command';

    if %data<command> :exists && %data<command> eq "SHUTDOWN" {
        $daemon.Shutdown();
        $r = "server shutdown complete";
    }
    return $r;
}
