module Stomp::Data;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Key;
use Stomp::Index;
use JSON::Tiny;

our sub add(Stomp::Key $key, Str $sitename, Str $username, Str $pw?)
returns Hash {
    if Stomp::Index::contains($key, $sitename) {
        err("{$sitename.lc} already exists");
    }
    my Str $password = $pw // Stomp::Utils::generate-password(16);
    my Str %data =
        :$sitename,
        :$username,
        :$password;
    my Str $json = to-json(%data);
    my Str $filename = Stomp::Utils::sha256(Stomp::Utils::random(32));
    write-data-file($filename, $key.encrypt($json));
    Stomp::Index::update($key, $sitename, $filename);
    return { :$sitename, :$username, :$password };
}

our sub edit(Stomp::Key $key, Str $sitename, %data) returns Hash {
    my $filename = Stomp::Index::get-filename($key, $sitename);
    write-data-file($filename, $key.encrypt(to-json(%data)));
    return %data;
}

our sub get(Stomp::Key $key, Str $sitename, Str $fn?) returns Hash {
    my $filename = $fn // Stomp::Index::get-filename($key, $sitename);
    my $data = from-json($key.decrypt(read-data-file($filename)));
    return $data;
}

our sub find(Stomp::Key $key, Str $searchterm) returns Array {
    my $index = Stomp::Index::get($key);
    my @found;
    for $index.kv -> $sitename, $filename {
        if $sitename ~~ m:i/ $searchterm / {
            @found.push(get($key, $sitename, $filename));
        }
    }
    return @found;
}

our sub list(Stomp::Key $key) returns Array {
    my $index = Stomp::Index::get($key);
    my @sites;
    for $index.kv -> $sitename, $filename {
        @sites.push(get($key, $sitename, $filename));
    }
    return @sites;
}

our sub remove(Stomp::Key $key, Str $sitename) returns Hash {
    my $filename = Stomp::Index::get-filename($key, $sitename);
    remove-data-file($filename);
    Stomp::Index::remove($key, $sitename);
    return { :$sitename };
}

our sub setup(Str :$auto) {
    header("Welcome to {PROGNAME()}");
    msg('getting things ready...');
    xmkdir($Stomp::Config::RootDir);
    xchmod(0o700, $Stomp::Config::RootDir);
    xmkdir($Stomp::Config::KeyDir);
    xmkdir($Stomp::Config::DataDir);
    msg("let's begin");

    my $pw = $auto // Stomp::Utils::ask-password(:confirm);
    $pw .= encode;
    my Buf $key = Stomp::Utils::random(1024 * 8);

    my $fh = xopen($Stomp::Config::Key);
    my $skey = Stomp::Key.new();
    $skey.rekey($pw);
    xwrite($fh, $skey.encrypt($key));
    xclose($fh);
    xchmod(0o400, $Stomp::Config::Key);
    xchmod(0o500, $Stomp::Config::KeyDir);

    $fh = xopen($Stomp::Config::Index);
    $skey.rekey($key);
    xwrite($fh, $skey.encrypt('{ }'));
    xclose($fh);

    copy('install/hooks', $Stomp::Config::Hooks);

    msg("all done, have fun!");
    exit(0) if not $auto;
    True; # return True when auto is enabled to help tests
}

our sub password(Stomp::Key $key, Str $sitename) returns Str {
    return get($key, $sitename)<password>;
}

sub write-data-file(Str $filename, Str $data) {
    my $fh = xopen($Stomp::Config::DataDir ~ "/$filename");
    xwrite($fh, $data);
    xclose($fh);
    xchmod(0o600, $Stomp::Config::DataDir ~ "/$filename");
}

sub remove-data-file(Str $filename) {
    xunlink($Stomp::Config::DataDir ~ "/$filename");
}

sub read-data-file(Str $filename) {
    return xslurp($Stomp::Config::DataDir ~ "/$filename");
}
