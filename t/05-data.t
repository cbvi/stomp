use Test;
use Stomp::Data;
use Stomp::Config;
use Stomp::Key;
use Shell::Command;

plan 21;

$Stomp::Config::RootDir = 't/testdir';
$Stomp::Config::KeyDir = 't/testdir/keys';
$Stomp::Config::DataDir = 't/testdir/data';
$Stomp::Config::Index = 't/testdir/index';
$Stomp::Config::Key = 't/testdir/keys/stompkey';
$Stomp::Config::Hooks = 't/testdir/hooks';

mkpath('t/testdir');
mkpath('t/testdir/data');

my $key = Stomp::Key.new;
$key.unlock('OxychromaticBlowfishSwatDynamite');

{
 Stomp::Data::add($key, 'example.org', 'dave', 'letmein123');
 Stomp::Data::add($key, 'FORTRAN', 'polish');

 my $data = Stomp::Data::get($key, 'example.org');

 is $data<sitename>, 'example.org', 'got sitename back';
 is $data<username>, 'dave', 'got username back';
 is $data<password>, 'letmein123', 'got password back';

 $data = Stomp::Data::get($key, 'fortran');
 is $data<sitename>, 'FORTRAN', 'get ignores case';
 is $data<username>, 'polish', 'correct data with ignored case';

 $data = Stomp::Data::get($key, 'fORTran');
 is $data<sitename>, 'FORTRAN', 'get with uppercase in requested name';
 is $data<username>, 'polish', 'correct data with uppercase name';
}

{
 my %newdata = username => 'sarah', password => 'hunter2',
    jabber => 'wocky', bandersnatch => 'frumious';
 Stomp::Data::edit($key, 'example.org', %newdata);
 my $data = Stomp::Data::get($key, 'example.org');

 is $data<username>, 'sarah', 'modified username';
 is $data<password>, 'hunter2', 'modified password';
 is $data<jabber>, 'wocky', 'new field jabber';
 is $data<bandersnatch>, 'frumious', 'new field bandersnatch';
}

{
 Stomp::Data::add($key, 'example.net', 'john');
 Stomp::Data::add($key, 'samples', 'cameron');

 my @find = Stomp::Data::find($key, 'example');
 is @find.elems, 2, 'correct number of elements found';

 @find = Stomp::Data::find($key, 'ample');
 is @find.elems, 3, 'found 3 results';

 @find = Stomp::Data::find($key, 'AMPLE');
 is @find.elems, 3, 'found 3 results with case mismatching search term';

 @find = Stomp::Data::find($key, 'fort');
 is @find[0]<username>, 'polish', 'find is case sensitive';

 @find = Stomp::Data::find($key, "I am a little teapot");
 is @find.elems, 0, 'found no results';
}

{
 my $later = Stomp::Data::add($key, 'deepweb', 'topsecret');
 my @list = Stomp::Data::list($key);
 my $expect;
 for @list -> $res {
    if $res<username> ~~ any('sarah', 'john', 'cameron') {
        $expect++;
    }
 }
 is $expect, 3, 'found expected entries in list';

 is Stomp::Data::password($key, 'deepweb'), $later<password>, 'got password';
}

{
 Stomp::Data::remove($key, 'deepweb');
 dies_ok { Stomp::Data::get($key, 'deepweb') }, 'removed entry';

 Stomp::Data::remove($key, 'foRTRAn');
 dies_ok { Stomp::Data::get($key, 'fortran') }, 'case insensitive remove';

 dies_ok { Stomp::Data::remove('zzfake') }, 'removing non-existent entry fails';
}

done();
