use v6;
use lib '.';
use Stomp::Key;
use Stomp::Data;

my $key = Stomp::Key.new;

my @sites = Stomp::Data::ListData($key);
for @sites {
    say .perl;
}

$key.Finish($key);
