use v6;
use lib '.';
use Stomp::Key;
use Stomp::Data;

my $key = Stomp::Key.new;

my @sites = Stomp::Data::FindData($key, 'wiki');
for @sites {
    say .perl;
}

$key.Finish($key);
