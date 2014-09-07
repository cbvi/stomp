use v6;
use lib '.';
use Stomp::Key;
use Stomp::Data;

my $key = Stomp::Key.new;

Stomp::Data::AddData($key, "test", "blah");

$key.Finish($key);
