use v6;
use Test;
use Shell::Command;

plan 1;

if not %*ENV<STOMP_NO_CLEAN> {
    chmod(0o700, 't/testdir/keys');
    chmod(0o700, 't/testdir/keys/stompkey');
    rm_rf('t/testdir');

    nok 't/testdir'.IO.d, 'remove testdir';
}
else {
    ok 1, 'no clean';
}

done();
