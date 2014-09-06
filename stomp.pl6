use v6;
use lib '.';
use Stomp;

Stomp.Setup();

Stomp.Usage() if not @*ARGS[0];

my Str $command = @*ARGS.shift;
my Str @options = @*ARGS;

Stomp.Command($command, @options);


# vim: ft=perl6
