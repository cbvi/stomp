use v6;
use lib 't';
use Test;
use Stomp::Daemon;
use STHelper;

plan *;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

STHelper::StartServer();

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
 my $req = Stomp::Utils::PrepareRequest("unlock",
    password => 'OpenUpAndLetMeIn');
 my $reply = Stomp::Utils::DoRequest($req);
 ok $reply<error>, 'error field was return with wrong password';
 is $reply<error>, 'password', 'error field is password';
}

{
 my $req = Stomp::Utils::PrepareRequest("key");
 my $reply = Stomp::Utils::DoRequest($req);
 is $reply<error>, 'locked', 'error is locked after key request while locked';

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

STHelper::StopServer();

done();
