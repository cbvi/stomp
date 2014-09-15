use v6;
use Test;
use Stomp::Daemon;

plan *;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

my $d = Stomp::Daemon.new();
my $t = Thread.new( code => { $d.StopCollaborateAndListen() } );

$t.run();

{
 my $req = Stomp::Utils::PrepareRequest("unlock",
    password => 'OxychromaticBlowfishSwatDynamite');
 my $reply = Stomp::Utils::DoRequest($req);
 is $reply<locked>, False, 'unlocked via daemon';
}

{
 my $req = Stomp::Utils::PrepareRequest("lock");
 my $reply = Stomp::Utils::DoRequest($req);
 is $reply<locked>, True, 'locked via daemon';
}

{
 my $req = Stomp::Utils::PrepareRequest("key");
 my $reply = Stomp::Utils::DoRequest($req);

 $req = Stomp::Utils::PrepareRequest("unlock",
    password => 'OxychromaticBlowfishSwatDynamite');
 $reply = Stomp::Utils::DoRequest($req);
 is $reply<locked>, False, 'unlocked after failed key request';
}

{
 my $req = Stomp::Utils::PrepareRequest("key");
 my $reply = Stomp::Utils::DoRequest($req);

 my $key = Stomp::Key.new();
 $key.Unlock('OxychromaticBlowfishSwatDynamite');
 is $reply<key>, $key.Key(), 'key matches';
}

{
 # FIXME shutting down the daemon in test causes weirdness, thread problem?
 my $req = Stomp::Utils::PrepareRequest("shutdown");
 Stomp::Utils::DoRequest($req);
 #skip 'Illegal attempt to pop empty temporary root stack';
 ok 1, 'still alive after shutdown';

 $req = Stomp::Utils::PrepareRequest("lock");
 dies_ok { Stomp::Utils::DoRequest($req) } , 'server is shutdown';
}

done();
