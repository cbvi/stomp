class Stomp::Key;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Client;

has Str $!DecodedKey;

has Bool $.Locked is rw = True;

method Smith() returns Stomp::Key {
    my $key = Stomp::Key.new();
    my $dk = Stomp::Client.Command('key');
    $key.Rekey($dk<key>);
    return $key;
}

method Rekey(Str $key) {
    $!DecodedKey = $key;
    $.Locked = False;
}

method Encrypt(Str $data) returns Str {
    return Stomp::Utils::Encrypt(self.Key(), $data);
}

method Decrypt(Str $data) returns Str {
    return Stomp::Utils::Decrypt(self.Key(), $data);
}

method Lock() {
    $!DecodedKey = Stomp::Utils::Random(8192);
    undefine $!DecodedKey;
    $.Locked = True;
}

method Unlock(Str $key) {
    my Str $enckey = readKey();
    $!DecodedKey = Stomp::Utils::Decrypt($key, $enckey);
    $.Locked = False;
} 

method Key() returns Str {
    return $!DecodedKey // panic("Key object has been destroyed");
}

method Finish(Stomp::Key $obj is rw) {
    if $obj !~~ self {
        panic("object given to Finish() must be itself");
    }
    $!DecodedKey = Stomp::Utils::Random(8192);
    undefine $!DecodedKey;
    undefine $obj;
}

sub readKey() {
    return xSlurp($Stomp::Config::Key);
} 

# vim: ft=perl6
