class Stomp::Key;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Daemon::Client;

has Blob $!DecodedKey;
has Str $!base64Key;

has Bool $.Locked is rw = True;

method Smith() returns Stomp::Key {
    my $key = Stomp::Key.new();
    my $dk = Stomp::Daemon::Client.Command('key');
    $key.Rekey(Stomp::Utils::base64-decode($dk<key>));
    return $key;
}

method Rekey(Blob $key) {
    $!DecodedKey = $key;
    $!base64Key = Str;
    $.Locked = False;
}

method Encrypt($data) returns Str {
    return Stomp::Utils::encrypt(self.Key(), $data);
}

method Decrypt(Str $data) {
    return Stomp::Utils::decrypt(self.Key(), $data);
}

method Lock() {
    undefine $!DecodedKey;
    undefine $!base64Key;
    $.Locked = True;
}

method Unlock(Str $password) {
    my Str $enckey = readKey();
    my $key = $password.encode;
    $!DecodedKey = Stomp::Utils::decrypt($key, $enckey);
    $.Locked = False;
} 

method Key() returns Blob {
    return $!DecodedKey // panic("Key object has been destroyed");
}

method Base64Key() returns Str {
    return $!base64Key if $!base64Key;
    $!base64Key = Stomp::Utils::base64-encode(self.Key());
    return $!base64Key;
}

method Finish(Stomp::Key $obj is rw) {
    if $obj !~~ self {
        panic("object given to Finish() must be itself");
    }
    undefine $!DecodedKey;
    undefine $obj;
}

sub readKey() {
    return xslurp($Stomp::Config::Key);
}

# vim: ft=perl6
