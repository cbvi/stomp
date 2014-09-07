use v6;
use lib '.';
use Stomp::Key;
use Stomp::Data;

my $key = Stomp::Key.new;

my %h =
    sitename => 'test',
    username => 'quux',
    password => 'letmein'
;

Stomp::Data::EditData($key, 'test', %h);

$key.Finish($key);
