use v6;

my $sync = Promise.new;

my $client = IO::Socket::Async.connect('127.0.0.1', 70291).then( -> $sr {
    my $socket = $sr.result;
    $socket.send("This is a test");
    my $tap = $socket.chars_supply.tap( -> $chars {
        say $chars;
        $sync.keep(1);
    });
});

await $client;
await $sync;

# vim: ft=perl6
