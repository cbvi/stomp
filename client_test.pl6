use v6;
use lib '.';
use Stomp::Client;

my Str @a = <testing123>;

my $json = Stomp::Client.Command('list', @a);

my $sock = IO::Socket::INET.new(host => '127.0.0.1', port => 70291);

$sock.send("LIST $json\n");

my $rec = '';
while (my $r = $sock.recv(1)) {
    next if $r eq "\n";
    $rec ~= $r;
}

say $rec;

# vim: ft=perl6
