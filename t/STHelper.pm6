module STHelper;

our sub set-config is export {
    $Stomp::Config::RootDir = 't/testdir';
    $Stomp::Config::KeyDir = 't/testdir/keys';
    $Stomp::Config::DataDir = 't/testdir/data';
    $Stomp::Config::Index = 't/testdir/index';
    $Stomp::Config::Key = 't/testdir/keys/stompkey';
    $Stomp::Config::Hooks = 't/testdir/hooks';
}

our sub start-server {
    if "t/server.pid".IO.e {
        stop-server(:nowait);
    }
    note '';
    shell("$*EXECUTABLE t/testserver.pl6 &");
    sleep(5);
}

our sub stop-server(Bool :$nowait?) {
    sleep(5) if not $nowait;
    my $pid = slurp("t/server.pid");
    note '';
    shell("kill -9 $pid");
    unlink("t/server.pid");
}
