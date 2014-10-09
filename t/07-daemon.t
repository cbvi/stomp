use v6;
use lib 't';
use Test;
use Stomp::Daemon;
use STHelper;

plan *;

set-config();
STHelper::start-server();

{
 my $req = Stomp::Utils::prepare-request("unlock",
    password => 'OxychromaticBlowfishSwatDynamite');
 my $reply = Stomp::Utils::do-request($req);
 is $reply<locked>, False, 'unlocked via daemon';
}

{
 my $req = Stomp::Utils::prepare-request("lock");
 my $reply = Stomp::Utils::do-request($req);
 is $reply<locked>, True, 'locked via daemon';
}

{
 my $req = Stomp::Utils::prepare-request("unlock",
    password => 'OpenUpAndLetMeIn');
 my $reply = Stomp::Utils::do-request($req);
 ok $reply<error>, 'error field was return with wrong password';
 is $reply<error>, 'password', 'error field is password';
}

{
 my $req = Stomp::Utils::prepare-request("key");
 my $reply = Stomp::Utils::do-request($req);
 is $reply<error>, 'locked', 'error is locked after key request while locked';

 $req = Stomp::Utils::prepare-request("unlock",
    password => 'OxychromaticBlowfishSwatDynamite');
 $reply = Stomp::Utils::do-request($req);
 is $reply<locked>, False, 'unlocked after failed key request';
}

{
 my $req = Stomp::Utils::prepare-request("key");
 my $reply = Stomp::Utils::do-request($req);

 my $key = Stomp::Key.new();
 $key.unlock('OxychromaticBlowfishSwatDynamite');
 is $reply<key>, Stomp::Utils::base64-encode($key.key()), 'key matches';
}

{
 # FIXME shutting down the daemon in test causes weirdness, thread problem?
 my $req = Stomp::Utils::prepare-request("shutdown");
 note '';
 Stomp::Utils::do-request($req);
 #skip 'Illegal attempt to pop empty temporary root stack';
 ok 1, 'still alive after shutdown';

 $req = Stomp::Utils::prepare-request("lock");
 dies_ok { Stomp::Utils::do-request($req) } , 'server is shutdown';
}

STHelper::stop-server();

done();
