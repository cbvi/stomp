use v6;

my $socket = IO::Socket::INET.new(
    host => '127.0.0.1',
    port => 70291
);

loop {
    $socket.send("ADDX\n");

    my $res = '';

    while (my $r = $socket.recv(1)) {
        if $r ne "\n" {
            $res ~= $r;
        }
        else {
            last;
        }
    }
    if $res eq "GOAHEAD" {
        $socket.send("some stuff\n");
    }
    say $res;
}

# vim: ft=perl6
