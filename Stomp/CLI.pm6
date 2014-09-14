class Stomp::CLI;

use Stomp::Client;
use Stomp::Data;
use Stomp::Utils;

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

method Edit(Str @options) {
    self.Usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.Smith();
    my $data = Stomp::Data::GetData($key, $sitename);

    for $data.kv -> $param, $value {
        next if $param eq <sitename>;
        my $newval = prompt("$param [$value]: ");
        $newval = $value if $newval eq '';
        $data{$param} = $newval;
    }

    while (Stomp::Utils::AskYesOrNo("add a new field?", :no)) {
        my $name = prompt("new field: ");
        next if $name eq "";
        if $data{$name} :exists {
            msg("'$name' field already exists");
            next;
        }
        my $value = prompt("$name: ");
        $data{$name} = $value;
    }

    for $data.kv -> $param, $value {
        say "$param: $value";
    }

    Stomp::Data::EditData($key, $sitename, $data);
}

method Get(Str @options) {
    self.Usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.Smith();
    my $data = Stomp::Data::GetData($key, $sitename);
    say $data.perl;
}

method Find(Str @options) {
    my $search = @options.shift;
    my $key = Stomp::Key.Smith();
    my @data = Stomp::Data::FindData($key, $search);

    for @data {
        say $_.perl;
    }
}

method List(Str @options) {
    my $key = Stomp::Key.Smith();
    my @data = Stomp::Data::ListData($key);
    for @data {
        say $_.perl;
    }
}

method Clip(Str @options) {
    self.Usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.Smith();
    my $password = Stomp::Data::PasswordData($key, $sitename);
    say $password;
}

method Generate(Str @options) {
    my $len = 16;
    my $set = 'a';

    my Str $o1;

    if @options.elems > 0  {
        if @options[0] ~~ / ^ <digit>* $ / {
            $len = @options[0];
            $o1 = "len";
        }
        elsif @options[0] ~~ / ^ <[as]> $ / {
            $set = @options[0];
            $o1 = "set";
        }
        else {
            self.Usage("didn't understand first parameter: {@options[0]}");
        }
    }

    if @options.elems > 1 {
        if @options[1] ~~ / ^ <[as]> $ / {
            self.Usage("can't specify set twice") if $o1 eq "set";
            $set = @options[1];
        }
        elsif @options[1] ~~ / ^ <digit>* $ / {
            self.Usage("can't specify length twice") if $o1 eq "len";
            $len = @options[1];
        }
        else {
            self.Usage("didn't understand second parameter: {@options[1]}");
        }
    }

    my Bool $special = $set eq 'a' ?? False !! True;
    my $length = $len.Int;
    say Stomp::Utils::GeneratePassword($length, :$special);
}
