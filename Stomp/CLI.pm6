class Stomp::CLI;

use Stomp::Client;
use Stomp::Data;

method Command(Str $command, Str @options) {
    given $command {
        when <add> { self.Add(@options) }
        when <get> { self.Get(@options) }
        when <find> { self.Find(@options) }
        when <edit> { self.Edit(@options) }
        when <list> { self.List(@options) }
        when <gen> { self.Generate(@options) }
        default { self.Usage() }
    }
}

method Add(Str @options) {
    self.Usage("must specify sitename and username") if @options.elems < 2;
    my $sitename = @options.shift;
    my $username = @options.shift;
    my $password = @options.shift // Str;

    my $key = Stomp::Key.Smith();
    Stomp::Data::AddData($key, $sitename, $username, $password);
}
