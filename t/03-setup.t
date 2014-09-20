use v6;
use Test;
use Stomp::Config;
use Stomp::Data;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

plan 1;

Stomp::Data::setup(auto => 'OxychromaticBlowfishSwatDynamite');

ok $Stomp::Config::RootDir.IO.d, 'root dir exists';

exit(0);
