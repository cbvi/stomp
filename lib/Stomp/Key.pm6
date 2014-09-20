class Stomp::Key;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Daemon::Client;

has Blob $!decoded-key;
has Str $!base64-decoded-key;

has Bool $.locked is rw = True;

method smith() returns Stomp::Key {
    my $key = Stomp::Key.new();
    my $dk = Stomp::Daemon::Client.command('key');
    $key.rekey(Stomp::Utils::base64-decode($dk<key>));
    return $key;
}

method rekey(Blob $key) {
    $!decoded-key = $key;
    $!base64-decoded-key = Str;
    $.locked = False;
}

method encrypt($data) returns Str {
    return Stomp::Utils::encrypt(self.key(), $data);
}

method decrypt(Str $data) {
    return Stomp::Utils::decrypt(self.key(), $data);
}

method lock() {
    undefine $!decoded-key;
    undefine $!base64-decoded-key;
    $.locked = True;
}

method unlock(Str $password) {
    my Str $enckey = read-key();
    my $key = $password.encode;
    $!decoded-key = Stomp::Utils::decrypt($key, $enckey);
    $.locked = False;
} 

method key() returns Blob {
    return $!decoded-key // panic("Key object has been destroyed");
}

method base64-key() returns Str {
    return $!base64-decoded-key if $!base64-decoded-key;
    $!base64-decoded-key = Stomp::Utils::base64-encode(self.key());
    return $!base64-decoded-key;
}

method finish(Stomp::Key $obj is rw) {
    if $obj !~~ self {
        panic("object given to Finish() must be itself");
    }
    undefine $!decoded-key;
    undefine $obj;
}

sub read-key() {
    return xslurp($Stomp::Config::Key);
}

# vim: ft=perl6
