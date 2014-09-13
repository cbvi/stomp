class Stomp::Client;

use Stomp::Utils;
use JSON::Tiny;

method Command(Str $command, Str @options) {
    given $command {
        when <add> { self.Add(@options) }
        when <get> { self.Get(@options) }
        when <find> { self.Find(@options) }
        when <edit> { self.Edit(@options) }
        when <list> { self.List(@options) }
        when <gen>  { self.Generate(@options) }
        when <x> | <clip> { self.Clip(@options) }
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
