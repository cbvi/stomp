use v6;
use Test;
use Stomp::Key;

plan 14;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

my $key = Stomp::Key.new();

ok $key.Locked, 'key is locked';
dies_ok { $key.Key() }, 'reading locked key dies';

$key.Unlock('OxychromaticBlowfishSwatDynamite');

nok $key.Locked, 'key is unlocked';
lives_ok { $key.Key() }, 'reading unlocked key works';

my $data = "One, two! One, two! and through and through\nThe vorpal blade went snicker-snack!";
my $enc = $key.Encrypt($data);
is $key.Decrypt($enc), $data, 'got decrypted data back';

$key.Lock();
ok $key.Locked, 'key was locked';
dies_ok { $key.Key() }, 'reading manually locked key dies';

dies_ok { $key.Encrypt("oh noes") }, 'encrypting while key is locked dies';
dies_ok { $key.Decrypt($enc) }, 'decrypting while key is locked dies';

$key.Unlock('OxychromaticBlowfishSwatDynamite');
my $original = $key.Key();

$key.Rekey("New key!");

isnt $key.Key(), $original, 'rekey changed the key';

dies_ok { $key.Decrypt($enc) }, 'dies decrypting with wrong key';

my $reenc = $key.Encrypt($data);
is $key.Decrypt($reenc), $data, 'correct data with modified key';

$key.Rekey($original);
is $key.Decrypt($enc), $data, 'changed key back';

$key.Finish($key);

nok $key.defined, 'Finish destroyed the key';

done();
