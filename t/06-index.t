use v6;
use Test;
use Stomp::Config;
use Stomp::Index;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

my $key = Stomp::Key.new();

$key.Unlock('OxychromaticBlowfishSwatDynamite');

Stomp::Index::UpdateIndex($key, 'fakesite', 'NOT_A_REAL_FILE');
my $index = Stomp::Index::GetIndex($key);

is $index<fakesite>, 'NOT_A_REAL_FILE', 'added and got index result';
$index{'fakesite'} :delete;

my $path = "{$Stomp::Config::DataDir}/{$index.pick(1).value}";
ok $path.IO.f, 'path to random file in index exists';
