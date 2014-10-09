use v6;
use lib 't';
use Test;
use Stomp::Daemon;
use Stomp::CLI;
use STHelper;

plan *;

set-config();
STHelper::start-server();

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
 $key.unlock('OxychromaticBlowfishSwatDynamite');
 my $data = Stomp::Data::get($key, 'example.com');
 is $data<username>, 'jwocky', 'data was added';
}

# TODO figure out ways of testing the other functions

STHelper::stop-server();

done();
