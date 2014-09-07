use v6;
use lib '.';
use Stomp::Key;
use Stomp::Data;

my $key = Stomp::Key.new;

say Stomp::Data::GetData($key, 'test');

$key.Finish($key);
