module STHelper;

our sub StartServer {
    if "t/server.pid".IO.e {
        StopServer(:nowait);
    }
    shell("$*EXECUTABLE t/testserver.pl6 &");
    sleep(5);
}

our sub StopServer(Bool :$nowait?) {
    sleep(5) if not $nowait;
    my $pid = slurp("t/server.pid");
    shell("kill -9 $pid");
    unlink("t/server.pid");
}
