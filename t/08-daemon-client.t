use v6;
use lib 't';
use Test;
use Stomp::Daemon;
use Stomp::Daemon::Client;
use Stomp::Key;
use STHelper;

plan *;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

STHelper::StartServer();

# Client unlock requires typing a password
sub test_unlock {
    my $req = Stomp::Utils::PrepareRequest("unlock",
        password => 'OxychromaticBlowfishSwatDynamite');
    Stomp::Utils::DoRequest($req);
}

{
 test_unlock;
 my $cli = Stomp::Daemon::Client.Command('lock');
 is $cli<locked>, True, 'locked via command';
}

{
 test_unlock;
 my $cli = Stomp::Daemon::Client.Command('key');
 ok $cli<key>, 'return key';
 my $key = Stomp::Key.new();
 $key.Unlock('OxychromaticBlowfishSwatDynamite');
 is $cli<key>, Stomp::Utils::Base64Encode($key.Key()), 'key matches';
}

{
 my $cli = Stomp::Daemon::Client.Command('shutdown');
 nok $cli, 'server was unable to send anything';
 ok 1, 'still alive after shutdown';
}

{
 dies_ok { Stomp::Daemon::Client.Command('lock') }, 'server is shutdown';
}

STHelper::StopServer();

done();
