class Stomp::Client;

use Stomp::Utils;
use Stomp::Config;
use JSON::Tiny;

my Str $parting-words;

method Command(Str $command, Str @options) {
    my Str $request = self.Dispatch($command, @options);
    my $sock = IO::Socket::INET.new( host => $Stomp::Config::Host,
        port => $Stomp::Config::Port);
    $sock.send("{$command.uc} $request\n");

    my $response = '';
    while (my $r = $sock.recv(1)) {
        next if $r eq "\n";
        $response ~= $r;
    }
    return $response;
}

method Dispatch(Str $command, Str @options) {
    given $command {
        when <add> { self.Add(@options) }
        when <get> { self.Get(@options) }
        when <find> { self.Find(@options) }
        when <edit> { self.Edit(@options) }
        when <list> { self.List(@options) }
        when <gen>  { self.Generate(@options) }
        when <x> | <clip> { self.Clip(@options) }
        when <server> { self.Server(@options) }
        default { self.Usage() }
    }
}

method Add(Str @options) {
    self.Usage("must specify sitename and username") if @options.elems < 2;
    my $sitename = @options.shift;
    my $username = @options.shift;
    my $password = @options.shift // Stomp::Utils::GeneratePassword(16);
    my %data =
        :$sitename,
        :$username,
        :$password
    ;
    return to-json(%data);
}

method Edit(Str @options) {
    self.Usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my %first = sitename => $sitename;
    die "FIX ME";
}

method Get(Str @options) {
    self.Usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my %data = :$sitename;
    return to-json(%data);
}

method Find(Str @options) {
    self.Usage("must specify search term") if @options.elems < 1;
    my $searchterm = @options.shift;
    my %data = :$searchterm;
    return to-json(%data);
}

method List(Str @options) {
    return '{  }';
}

method Server(Str @options) {
    self.Usage("must specify command") if @options.elems < 1;
    my $command = @options.shift;
    my %data = :$command;
    say "server issued $command command";
    $parting-words = "done";
    return to-json(%data);
}

method Usage(Str $hint?) {
    msg($hint) if $hint;
    say "\t$*PROGRAM add sitename username [password]";
    say "\t$*PROGRAM get sitename";
    say "\t$*PROGRAM find sitename";
    say "\t$*PROGRAM list";
    say "\t$*PROGRAM edit sitename";
    say "\t$*PROGRAM gen [a = alphanumerical|s = include symbols] [length]";
    say "\t$*PROGRAM [x|clip] sitename";
    exit(0);
}

END {
    if $parting-words {
        say $parting-words;
    }
}
