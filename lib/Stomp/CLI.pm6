class Stomp::CLI;

use Stomp::Daemon::Client;
use Stomp::Data;
use Stomp::Utils;

method command(Str $command, Str @options) {
    given $command {
        when <add>          { self.add(@options) }
        when <get>          { self.get(@options) }
        when <remove>       { self.remove(@options) }
        when <find>         { self.find(@options) }
        when <edit>         { self.edit(@options) }
        when <list>         { self.list(@options) }
        when <gen>          { self.generate(@options) }
        when <x> | <clip>   { self.clip(@options) }
        when <admin>        { self.admin(@options) }
        default             { self.usage() }
    }
}

method add(Str @options) {
    self.usage("must specify sitename and username") if @options.elems < 2;
    my Bool $interactive = False;
    if @options[0] eq '-i' {
        $interactive = True;
        @options.shift;
    }
    my $sitename = @options.shift;
    my $username = @options.shift;
    my Str $password;
    $password = Stomp::Utils::ask-password("password for $sitename: ")
        if $interactive;

    my $key = Stomp::Key.Smith();
    my $data = Stomp::Data::AddData($key, $sitename, $username, $password);

    header($sitename);
    msg("added");
    say $data<password> if not $interactive;
}

method edit(Str @options) {
    self.usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.Smith();
    my $data = Stomp::Data::GetData($key, $sitename);

    for $data.kv -> $param, $value {
        next if $param eq <sitename>;
        my $newval = prompt("$param [$value]: ");
        $newval = $value if $newval eq '';
        $data{$param} = $newval;
    }

    while (Stomp::Utils::ask-yes-or-no("add a new field?", :no)) {
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

method get(Str @options) {
    self.usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.Smith();
    my $data = Stomp::Data::GetData($key, $sitename);

    header($sitename);
    for $data.kv -> $param, $value {
        say "$param: $value";
    }
}

method remove(Str @options) {
    self.usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.Smith();
    my $sure = Stomp::Utils::ask-yes-or-no("delete $sitename?", :no);
    err("aborted!") if not $sure;
    Stomp::Data::RemoveData($key, $sitename);
    msg("removed $sitename");
}

method find(Str @options) {
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

method list(Str @options) {
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

method clip(Str @options) {
    self.usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.Smith();
    my $password = Stomp::Data::PasswordData($key, $sitename);
    say $password;
}

method generate(Str @options) {
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
            self.usage("didn't understand first parameter: {@options[0]}");
        }
    }

    if @options.elems > 1 {
        if @options[1] ~~ / ^ <[as]> $ / {
            self.usage("can't specify set twice") if $o1 eq "set";
            $set = @options[1];
        }
        elsif @options[1] ~~ / ^ <digit>* $ / {
            self.usage("can't specify length twice") if $o1 eq "len";
            $len = @options[1];
        }
        else {
            self.usage("didn't understand second parameter: {@options[1]}");
        }
    }

    my Bool $special = $set eq 'a' ?? False !! True;
    my $length = $len.Int;
    say Stomp::Utils::generate-password($length, :$special);
}

method admin(Str @options) {
    self.usage("must specify command to send to server") if @options.elems < 1;
    my $command = @options.shift;
    Stomp::Daemon::Client.Command($command);
}

method setup() {
    Stomp::Data::SetupData();
}

method usage(Str $hint?) {
    msg($hint) if $hint;
    say "\t$*PROGRAM_NAME add [-i] sitename username";
    say "\t$*PROGRAM_NAME get sitename";
    say "\t$*PROGRAM_NAME remove sitename";
    say "\t$*PROGRAM_NAME find sitename";
    say "\t$*PROGRAM_NAME list";
    say "\t$*PROGRAM_NAME edit sitename";
    say "\t$*PROGRAM_NAME gen [as] [length]";
    say "\t$*PROGRAM_NAME clip|x sitename";
    say "\t$*PROGRAM_NAME admin [lock|unlock|key|shutdown]";
    exit(0);
}
