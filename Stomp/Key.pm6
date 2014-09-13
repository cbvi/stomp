class Stomp::Key;

use Stomp::Config;
use Stomp::Utils;

my Str $decodedKey;

has Bool $.Locked is rw = True;

method Encrypt(Str $data) returns Str {
    return Stomp::Utils::Encrypt(key(), $data);
}

method Decrypt(Str $data) returns Str {
    return Stomp::Utils::Decrypt(key(), $data);
}

method Lock() {
    $decodedKey = Stomp::Utils::Random(8192);
    undefine $decodedKey;
    $.Locked = True;
}

method Unlock(Str $key) {
    my Str $enckey = readKey();
    $decodedKey = Stomp::Utils::Decrypt($key, $enckey);
    $.Locked = False;
} 

method GetKey() {
    return key();
}

method Finish(Stomp::Key $obj is rw) {
    if $obj !~~ self {
        panic("object given to Finish() must be itself");
    }
    $decodedKey = Stomp::Utils::Random(8192);
    undefine $decodedKey;
    undefine $obj;
}

sub key returns Str {
    return $decodedKey // panic("Key object has been destroyed");
}

sub readKey() {
    return xSlurp($Stomp::Config::Key);
} 

# vim: ft=perl6
