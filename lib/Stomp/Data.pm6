module Stomp::Data;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Key;
use Stomp::Index;
use JSON::Tiny;

our sub AddData(Stomp::Key $key, Str $sitename, Str $username, Str $pw?)
returns Hash {
    my $index = Stomp::Index::GetIndex($key);
    if $index{$sitename} :exists {
        err("$sitename already exists");
    }
    my Str $password = $pw // Stomp::Utils::GeneratePassword(16);
    my Str %data =
        :$sitename,
        :$username,
        :$password;
    my Str $json = to-json(%data);
    my Str $filename = Stomp::Utils::Sha256(Stomp::Utils::Random(32));
    writeDataFile($filename, $key.Encrypt($json));
    Stomp::Index::UpdateIndex($key, $sitename, $filename);
    return { :$sitename, :$username, :$password };
}

our sub EditData(Stomp::Key $key, Str $sitename, %data) returns Hash {
    my $filename = getFilenameFromIndex($key, $sitename);
    writeDataFile($filename, $key.Encrypt(to-json(%data)));
    return %data;
}

our sub GetData(Stomp::Key $key, Str $sitename, Str $fn?) returns Hash {
    my $filename = $fn // getFilenameFromIndex($key, $sitename);
    my $data = from-json($key.Decrypt(readDataFile($filename)));
    return $data;
}

our sub FindData(Stomp::Key $key, Str $searchterm) returns Array {
    my $index = Stomp::Index::GetIndex($key);
    my @found;
    for $index.kv -> $sitename, $filename {
        if $sitename ~~ / $searchterm / {
            @found.push(GetData($key, $sitename, $filename));
        }
    }
    return @found;
}

our sub ListData(Stomp::Key $key) returns Array {
    my $index = Stomp::Index::GetIndex($key);
    my @sites;
    for $index.kv -> $sitename, $filename {
        @sites.push(GetData($key, $sitename, $filename));
    }
    return @sites;
}

our sub SetupData(Str :$auto) {
    header("Welcome to $*PROGRAM_NAME");
    msg('getting things ready...');
    xMkdir($Stomp::Config::RootDir);
    xChmod(0o700, $Stomp::Config::RootDir);
    xMkdir($Stomp::Config::KeyDir);
    xMkdir($Stomp::Config::DataDir);
    msg("let's begin");

    my $pw = $auto // AskPassword(:confirm);
    my $key = Stomp::Utils::Random(1024 * 5);

    my $fh = xOpen($Stomp::Config::Key);
    my $skey = Stomp::Key.new();
    $skey.Rekey($pw);
    xWrite($fh, $skey.Encrypt($key));
    xClose($fh);
    xChmod(0o400, $Stomp::Config::Key);
    xChmod(0o500, $Stomp::Config::KeyDir);

    $fh = xOpen($Stomp::Config::Index);
    $skey.Rekey($key);
    xWrite($fh, $skey.Encrypt('{ }'));
    xClose($fh);

    msg("all done, have fun!");
    exit(0) if not $auto;
}

our sub PasswordData(Stomp::Key $key, Str $sitename) returns Str {
    return GetData($key, $sitename)<password>;
}

sub getFilenameFromIndex(Stomp::Key $key, Str $sitename) {
    my $index = Stomp::Index::GetIndex($key);
    return $index{$sitename} // err("cannot find $sitename");
}

sub writeDataFile(Str $filename, Str $data) {
    my $fh = xOpen($Stomp::Config::DataDir ~ "/$filename");
    xWrite($fh, $data);
    xClose($fh);
    xChmod(0o600, $Stomp::Config::DataDir ~ "/$filename");
}

sub readDataFile(Str $filename) {
    return xSlurp($Stomp::Config::DataDir ~ "/$filename");
}
