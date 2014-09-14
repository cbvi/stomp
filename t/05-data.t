use Test;
use Stomp::Data;
use Stomp::Config;
use Stomp::Key;
use Shell::Command;

plan 12;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';

mkpath('t/testdir');
mkpath('t/testdir/data');

my $key = Stomp::Key.new;
$key.Unlock('OxychromaticBlowfishSwatDynamite');

{
 Stomp::Data::AddData($key, 'example.org', 'dave', 'letmein123');

 my $data = Stomp::Data::GetData($key, 'example.org');

 is $data<sitename>, 'example.org', 'got sitename back';
 is $data<username>, 'dave', 'got username back';
 is $data<password>, 'letmein123', 'got password back';
}

{
 my %newdata = username => 'sarah', password => 'hunter2',
    jabber => 'wocky', bandersnatch => 'frumious';
 Stomp::Data::EditData($key, 'example.org', %newdata);
 my $data = Stomp::Data::GetData($key, 'example.org');

 is $data<username>, 'sarah', 'modified username';
 is $data<password>, 'hunter2', 'modified password';
 is $data<jabber>, 'wocky', 'new field jabber';
 is $data<bandersnatch>, 'frumious', 'new field bandersnatch';
}

{
 Stomp::Data::AddData($key, 'example.net', 'john');
 Stomp::Data::AddData($key, 'samples', 'cameron');

 my @find = Stomp::Data::FindData($key, 'example');
 is @find.elems, 2, 'correct number of elements found';

 @find = Stomp::Data::FindData($key, 'ample');
 is @find.elems, 3, 'found 3 results';

 @find = Stomp::Data::FindData($key, "I am a little teapot");
 is @find.elems, 0, 'found no results';
}

{
 my $later = Stomp::Data::AddData($key, 'deepweb', 'topsecret');
 my @list = Stomp::Data::ListData($key);
 my $expect;
 for @list -> $res {
    if $res<username> ~~ any('sarah', 'john', 'cameron') {
        $expect++;
    }
 }
 is $expect, 3, 'found expected entries in list';

 is Stomp::Data::PasswordData($key, 'deepweb'), $later<password>, 'got password';
}

done();
