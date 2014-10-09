use v6;
use lib 't';
use Test;
use Stomp::Daemon;
use Stomp::Daemon::Client;
use Stomp::Key;
use STHelper;

plan *;

set-config();
STHelper::start-server();

# Client unlock requires typing a password
sub test_unlock {
    my $req = Stomp::Utils::prepare-request("unlock",
        password => 'OxychromaticBlowfishSwatDynamite');
    Stomp::Utils::do-request($req);
}

{
 test_unlock;
 my $cli = Stomp::Daemon::Client.command('lock');
 is $cli<locked>, True, 'locked via command';
}

{
 test_unlock;
 my $cli = Stomp::Daemon::Client.command('key');
 ok $cli<key>, 'return key';
 my $key = Stomp::Key.new();
 $key.unlock('OxychromaticBlowfishSwatDynamite');
 is $cli<key>, Stomp::Utils::base64-encode($key.key()), 'key matches';
}

{
 note '';
 my $cli = Stomp::Daemon::Client.command('shutdown');
 nok $cli, 'server was unable to send anything';
 ok 1, 'still alive after shutdown';
}

{
 dies_ok { Stomp::Daemon::Client.command('lock') }, 'server is shutdown';
}

STHelper::stop-server();

done();
