use v6;
use lib '.';
use Stomp::Client;

Stomp::Client.Usage() if not @*ARGS[0];

my Str $command = @*ARGS.shift;
my Str @options = @*ARGS;

say Stomp::Client.Command($command, @options);

# vim: ft=perl6
