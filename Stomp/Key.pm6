class Stomp::Key;

use Stomp::Config;
use Stomp::Utils;

my Str $decodedKey;

method new() {
    my Str $enckey = readKey();
    $decodedKey = Stomp::Utils::decrypt("lep", $enckey);
    return self.bless();
}

method Encrypt(Str $data) returns Str {
    return Stomp::Utils::encrypt(key(), $data);
}

method Decrypt(Str $data) returns Str {
    return Stomp::Utils::decrypt(key(), $data);
}

method Finish(Stomp::Key $obj is rw) {
    if $obj !~~ self {
        Stomp::Utils::panic("object given to Finish() must be itself");
    }
    $decodedKey = Stomp::Utils::random($decodedKey.chars);
    undefine $decodedKey;
    undefine $obj;
}

sub key returns Str {
    return $decodedKey // Stomp::Utils::panic("Key object has been destroyed");
}

sub readKey() {
    return xSlurp($Stomp::Config::Key);
} 

# vim: ft=perl6
