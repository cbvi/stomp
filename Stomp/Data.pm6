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

    header($sitename);
    say $password;
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
