class Stomp::CLI;

use Stomp::Daemon::Client;
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
        when <admin> { self.Admin(@options) }
        default { self.Usage() }
    }
}

method Add(Str @options) {
    self.Usage("must specify sitename and username") if @options.elems < 2;
    my Bool $interactive = False;
    if @options[0] eq '-i' {
        $interactive = True;
        @options.shift;
    }
    my $sitename = @options.shift;
    my $username = @options.shift;
    my Str $password;
    $password = AskPassword("password for $sitename: ") if $interactive;

    my $key = Stomp::Key.Smith();
    my $data = Stomp::Data::AddData($key, $sitename, $username, $password);

    header($sitename);
    msg("added");
    say $data<password> if not $interactive;
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

    Stomp::Data::EditData($key, $sitename, $data);

    header($sitename);
    msg("updated");

    for $data.kv -> $param, $value {
        say "$param: $value";
    }
}

method Get(Str @options) {
    self.Usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.Smith();
    my $data = Stomp::Data::GetData($key, $sitename);

    header($sitename);
    for $data.kv -> $param, $value {
        say "$param: $value";
    }
}

method Find(Str @options) {
    my $search = @options.shift;
    my $key = Stomp::Key.Smith();
    my @data = Stomp::Data::FindData($key, $search);

    for @data -> $site {
        my $s = $site<sitename>;
        print $s;
        print " " xx ($s.chars < 16 ?? 16 - $s.chars !! 16);
        print "({$site<username>})";
        say();
    }
}

method List(Str @options) {
    my $key = Stomp::Key.Smith();
    my @data = Stomp::Data::ListData($key);
    for @data -> $site {
        my $s = $site<sitename>;
        print $site<sitename>;
        print " " xx ($s.chars < 16 ?? 16 - $s.chars !! 16);
        print "({$site<username>})";
        say();
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

method Admin(Str @options) {
    self.Usage("must specify command to send to server") if @options.elems < 1;
    my $command = @options.shift;
    Stomp::Daemon::Client.Command($command);
}

method Setup() {
    Stomp::Data::SetupData();
}

method Usage(Str $hint?) {
    msg($hint) if $hint;
    say "\t$*PROGRAM_NAME add [-i] sitename username";
    say "\t$*PROGRAM_NAME get sitename";
    say "\t$*PROGRAM_NAME find sitename";
    say "\t$*PROGRAM_NAME list";
    say "\t$*PROGRAM_NAME edit sitename";
    say "\t$*PROGRAM_NAME gen [as] [length]";
    say "\t$*PROGRAM_NAME [x|clip] sitename";
    exit(0);
}
