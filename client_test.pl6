use v6;
use JSON::Tiny;

my %h = searchterm => 'Lighthouse';

my $json = to-json(%h);
say $json;

my $sock = IO::Socket::INET.new(host => '127.0.0.1', port => 70291);

$sock.send("LIST $json\n");

my $rec = '';
while (my $r = $sock.recv(1)) {
    next if $r eq "\n";
    $rec ~= $r;
}

say $rec;

# vim: ft=perl6
