use v6;
use lib '.';
use Stomp::Key;
use Stomp::Index;

my $key = Stomp::Key.new;

say Stomp::Utils::generatePassword(16, :special);

$key.Finish($key);
