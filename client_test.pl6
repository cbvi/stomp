use v6;
use lib '.';
use Stomp::Client;

Stomp::Client.Usage() if not @*ARGS[0];

my Str $command = @*ARGS.shift;
my Str @options = @*ARGS;

my $json = Stomp::Client.Command($command, @options);

my $sock = IO::Socket::INET.new(host => '127.0.0.1', port => 70291);
$sock.send("{$command.uc} $json\n");

my $rec = '';
while (my $r = $sock.recv(1)) {
    next if $r eq "\n";
    $rec ~= $r;
}

say $rec;

# vim: ft=perl6
