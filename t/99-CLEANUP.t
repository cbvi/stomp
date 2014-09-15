use v6;
use Test;
use Shell::Command;

plan 1;

chmod(0o700, 't/testdir/keys');
chmod(0o700, 't/testdir/keys/stompkey');

rm_rf('t/testdir');

nok 't/testdir'.IO.d, 'remove testdir';

done();
