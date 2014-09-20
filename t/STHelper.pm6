module STHelper;

our sub StartServer {
    shell("$*EXECUTABLE t/testserver.pl6 &");
    sleep(5);
}

our sub StopServer {
    sleep(5);
    my $pid = slurp("t/server.pid");
    shell("kill -9 $pid");
    unlink("t/server.pid");
}
