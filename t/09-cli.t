use v6;
use Test;
use Stomp::Daemon;
use Stomp::CLI;

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
 # cheat to get the key unlocked so we can test without entering a password
 my $req = Stomp::Utils::PrepareRequest("unlock",
    password => 'OxychromaticBlowfishSwatDynamite');
 Stomp::Utils::DoRequest($req);
 sleep(2);
}

{
 my $command = 'add';
 my Str @options = <example.com jwocky>;
 Stomp::CLI.Command($command, @options);
}

{
 my $key = Stomp::Key.new();
 $key.Unlock('OxychromaticBlowfishSwatDynamite');
 my $data = Stomp::Data::GetData($key, 'example.com');
 is $data<username>, 'jwocky', 'data was added';
}

# TODO figure out ways of testing the other functions

done();
