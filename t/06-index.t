use v6;
use Test;
use Stomp::Config;
use Stomp::Index;
use Stomp::Data;

plan 9;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';
$Stomp::Config::Hooks = 't/testdir/hooks';

my $key = Stomp::Key.new();

$key.unlock('OxychromaticBlowfishSwatDynamite');

{
 Stomp::Index::update($key, 'fakesite', 'NOT_A_REAL_FILE');
 my $index = Stomp::Index::get($key);

 is $index<fakesite>, 'NOT_A_REAL_FILE', 'added and got index result';
 $index{'fakesite'} :delete;

 my $path = "{$Stomp::Config::DataDir}/{$index.pick(1).value}";
 ok $path.IO.f, 'path to random file in index exists';
}

{
 Stomp::Index::update($key, 'fakesiteagain', 'NOT_A_REAL_FILE_AGAIN');
 my $index = Stomp::Index::get($key);
 is $index<fakesiteagain>, 'NOT_A_REAL_FILE_AGAIN', 'entry was added';

 Stomp::Index::remove($key, 'fakesiteagain');
 $index = Stomp::Index::get($key);
 nok $index{'fakesiteagain'} :exists, 'entry was removed';
}

{
 Stomp::Index::update($key, 'MixedCaseName', 'MIXED_CASE_FAKE_FILE');
 my $index = Stomp::Index::get($key);
 my Bool $sanity = False;

 for $index.kv -> $key, $value {
    if $key ~~ m:i/ MixedCaseName / {
        $sanity = True;
    }
 }
 ok $sanity, 'entry was added and can be checked using this method';
}

{
 Stomp::Index::remove($key, 'mixedcaseNAME');
 my $index = Stomp::Index::get($key);
 my Bool $okay = True;

 for $index.kv -> $key, $value {
    if $key ~~ m:i/ MixedCaseName / {
        $okay = False;
    }
 }
 ok $okay, 'removed entry added with mixed case name';
}

{
 Stomp::Data::add($key, 'testdataindex', 'INDEX_DATA_FILE');
 Stomp::Data::remove($key, 'TESTdataINDEX');
 my $index = Stomp::Index::get($key);
 nok $index{'testdataindex'} :exists, 'Data::remove removes from index';
}

{
 Stomp::Data::add($key, 'ShouldBeDeleted', 'DELETED_DATA_FILE');
 my $index = Stomp::Index::get($key);
 my $filename = $index<shouldbedeleted>;
 my $path = $Stomp::Config::DataDir ~ '/' ~ $filename;

 ok $path.IO.e, 'data file exists';
 Stomp::Data::remove($key, 'ShouldbeDELETED');
 nok $path.IO.e, 'data file deleted';
}

done();

# vim: ft=perl6
