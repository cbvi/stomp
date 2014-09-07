class Stomp::Key;

use Stomp::Config;
use Stomp::Utils;

my Str $decodedKey;

method new() {
    my Str $enckey = readKey();
    $decodedKey = Stomp::Utils::Decrypt("lep", $enckey);
    return self.bless();
}

method Encrypt(Str $data) returns Str {
    return Stomp::Utils::Encrypt(key(), $data);
}

method Decrypt(Str $data) returns Str {
    return Stomp::Utils::Decrypt(key(), $data);
}

method Finish(Stomp::Key $obj is rw) {
    if $obj !~~ self {
        panic("object given to Finish() must be itself");
    }
    $decodedKey = Stomp::Utils::Random($decodedKey.chars);
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
