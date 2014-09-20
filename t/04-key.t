use v6;
use Test;
use Stomp::Key;
use Stomp::Utils;

plan 17;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

my $key = Stomp::Key.new();

ok $key.locked, 'key is locked';
dies_ok { $key.key() }, 'reading locked key dies';

$key.unlock('OxychromaticBlowfishSwatDynamite');

nok $key.locked, 'key is unlocked';
lives_ok { $key.key() }, 'reading unlocked key works';

is Stomp::Utils::base64-encode($key.key()), $key.base64-key(), 'base64 key';

my $data = "One, two! One, two! and through and through\nThe vorpal blade went snicker-snack!";
my $enc = $key.encrypt($data);
is $key.decrypt($enc), $data, 'got decrypted data back';

$key.lock();
ok $key.locked, 'key was locked';
dies_ok { $key.key() }, 'reading manually locked key dies';

dies_ok { $key.encrypt("oh noes") }, 'encrypting while key is locked dies';
dies_ok { $key.decrypt($enc) }, 'decrypting while key is locked dies';

$key.unlock('OxychromaticBlowfishSwatDynamite');
my $original = $key.key();
my $originalbase64 = $key.base64-key();

$key.rekey("New key!".encode);

isnt $key.key(), $original, 'rekey changed the key';

is Stomp::Utils::base64-encode($key.key()), $key.base64-key(),
    'rekeying resets the base64 key';

dies_ok { $key.decrypt($enc) }, 'dies decrypting with wrong key';

my $reenc = $key.encrypt($data);
is $key.decrypt($reenc), $data, 'correct data with modified key';

$key.rekey($original);
is $key.decrypt($enc), $data, 'changed key back';
is $key.base64-key(), $originalbase64, 'base64 key matches original';

$key.finish($key);

nok $key.defined, 'Finish destroyed the key';

done();
