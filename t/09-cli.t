use v6;
use lib 't';
use Test;
use Stomp::Daemon;
use Stomp::CLI;
use STHelper;

plan *;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

STHelper::StartServer();

{
 # cheat to get the key unlocked so we can test without entering a password
 my $req = Stomp::Utils::prepare-request("unlock",
    password => 'OxychromaticBlowfishSwatDynamite');
 Stomp::Utils::do-request($req);
 sleep(2);
}

{
 my $command = 'add';
 my Str @options = <example.com jwocky>;
 Stomp::CLI.command($command, @options);
}

{
 my $key = Stomp::Key.new();
 $key.Unlock('OxychromaticBlowfishSwatDynamite');
 my $data = Stomp::Data::GetData($key, 'example.com');
 is $data<username>, 'jwocky', 'data was added';
}

# TODO figure out ways of testing the other functions

STHelper::StopServer();

done();
