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
        when <obliterate>   { self.obliterate(@options) }
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

    my $key = Stomp::Key.smith();
    my $data = Stomp::Data::add($key, $sitename, $username, $password);

    header($sitename);
    msg("added");
    say $data<password> if not $interactive;
}

method edit(Str @options) {
    self.usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.smith();
    my $data = Stomp::Data::get($key, $sitename);

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

    Stomp::Data::edit($key, $sitename, $data);

    header($sitename);
    msg("updated");

    for $data.kv -> $param, $value {
        say "$param: $value";
    }
}

method get(Str @options) {
    self.usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.smith();
    my $data = Stomp::Data::get($key, $sitename);

    header($sitename);
    for $data.kv -> $param, $value {
        say "$param: $value";
    }
}

method remove(Str @options) {
    self.usage("must specify sitename") if @options.elems < 1;
    my $sitename = @options.shift;
    my $key = Stomp::Key.smith();
    my $sure = Stomp::Utils::ask-yes-or-no("delete $sitename?", :no);
    err("aborted!") if not $sure;
    Stomp::Data::remove($key, $sitename);
    msg("removed $sitename");
}

method find(Str @options) {
    my $search = @options.shift;
    my $key = Stomp::Key.smith();
    my @data = Stomp::Data::find($key, $search);

    for @data -> $site {
        my $s = $site<sitename>;
        print $s;
        print " " xx ($s.chars < 16 ?? 16 - $s.chars !! 16);
        print "({$site<username>})";
        say();
    }
}

method list(Str @options) {
    my $key = Stomp::Key.smith();
    my @data = Stomp::Data::list($key);
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
    my $key = Stomp::Key.smith();
    my $password = Stomp::Data::password($key, $sitename);
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
    Stomp::Daemon::Client.command($command);
}

method obliterate(Str @options) {
    msg("you are about to delete *EVERYTHING*");
    msg("there is no way to undo this");
    msg("type 'BEWARE THE JABBERWOCK' to confirm");
    my $confirm = prompt("Confirm: ");
    if $confirm eq "BEWARE THE JABBERWOCK" {
        use Shell::Command;
        msg("orbital bombardment in progress...");
        xchmod(0o700, $Stomp::Config::KeyDir);
        xchmod(0o700, $Stomp::Config::Key);
        rm_rf($Stomp::Config::RootDir);
        if $Stomp::Config::Key.IO !~~ :e {
            msg("all your data has been nuked from orbit");
            msg("I hope you do not regret this decision");
        }
        else {
            err("there still appears to still be some signs of life");
            err("you have to manually clean up");
        }
    }
    else {
        err("orbital bombardment aborted!");
    }
}

method setup() {
    Stomp::Data::setup();
}

method usage(Str $hint?) {
    my $prog = PROGNAME();
    msg($hint) if $hint;
    say "\t$prog add [-i] sitename username";
    say "\t$prog get sitename";
    say "\t$prog remove sitename";
    say "\t$prog find sitename";
    say "\t$prog list";
    say "\t$prog edit sitename";
    say "\t$prog gen [as] [length]";
    say "\t$prog clip|x sitename";
    say "\t$prog admin [lock|unlock|key|shutdown]";
    exit(0);
}
