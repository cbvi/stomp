module Stomp::Data;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Key;
use Stomp::Index;
use JSON::Tiny;

our sub AddData(Stomp::Key $key, Str $sitename, Str $username, Str $pw?) {
    my Str $password = $pw // Stomp::Utils::GeneratePassword(16);
    my Str %data =
        :$sitename,
        :$username,
        :$password
    ;
    my Str $json = to-json(%data);
    my Str $filename = Stomp::Utils::Sha256(Stomp::Utils::Random(32));
    writeDataFile($filename, $key.Encrypt($json));
    Stomp::Index::UpdateIndex($key, $sitename, $filename);
}

our sub EditData(Stomp::Key $key, Str $sitename, %data) {
    my $filename = getFilenameFromIndex($key, $sitename);
    writeDataFile($filename, $key.Encrypt(to-json(%data)));
}

our sub GetData(Stomp::Key $key, Str $sitename, Str $fn?) returns Hash {
    my $filename = $fn // getFilenameFromIndex($key, $sitename);
    my $data = from-json($key.Decrypt(readDataFile($filename)));
    return $data;
}

our sub FindData(Stomp::Key $key, Str $searchterm) returns Array {
    my $index = from-json(Stomp::Index::GetIndex($key));
    my @found;
    for $index.kv -> $sitename, $filename {
        if $sitename ~~ / $searchterm / {
            @found.push(GetData($key, $sitename, $filename));
        }
    }
    return @found;
}

our sub ListData(Stomp::Key $key) returns Array {
    my $index = from-json(Stomp::Index::GetIndex($key));
    my @sites;
    for $index.kv -> $sitename, $filename {
        @sites.push(GetData($key, $sitename, $filename));
    }
    return @sites;
}

our sub PasswordData(Stomp::Key $key, Str $sitename) returns Str {
    return GetData($key, $sitename)<password>;
}

sub getFilenameFromIndex(Stomp::Key $key, Str $sitename) {
    my $index = from-json(Stomp::Index::GetIndex($key));
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
