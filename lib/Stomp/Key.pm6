class Stomp::Key;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Daemon::Client;
use MIME::Base64;

has Str $!base64DecodedKey;

has Bool $.Locked is rw = True;

method Smith() returns Stomp::Key {
    my $key = Stomp::Key.new();
    my $dk = Stomp::Daemon::Client.Command('key');
    $key.Rekey(MIME::Base64.decode($dk<key>));
    return $key;
}

method Rekey(Blob $key) {
    $!base64DecodedKey = MIME::Base64.encode($key);
    $.Locked = False;
}

method Encrypt($data) returns Str {
    return Stomp::Utils::Encrypt(self.Key(), $data);
}

method Decrypt(Str $data) {
    return Stomp::Utils::Decrypt(self.Key(), $data);
}

method Lock() {
    $!base64DecodedKey = MIME::Base64.encode(Stomp::Utils::Random(8192));
    undefine $!base64DecodedKey;
    $.Locked = True;
}

method Unlock(Str $password) {
    my Str $enckey = readKey();
    my $key = MIME::Base64.encode($password.encode);
    $!base64DecodedKey = MIME::Base64.encode(Stomp::Utils::Decrypt($key, $enckey));
    $.Locked = False;
} 

method Key() returns Str {
    return $!base64DecodedKey // panic("Key object has been destroyed");
}

method Finish(Stomp::Key $obj is rw) {
    if $obj !~~ self {
        panic("object given to Finish() must be itself");
    }
    $!base64DecodedKey = MIME::Base64.encode(Stomp::Utils::Random(8192));
    undefine $!base64DecodedKey;
    undefine $obj;
}

sub readKey() {
    return xSlurp($Stomp::Config::Key);
} 

# vim: ft=perl6
