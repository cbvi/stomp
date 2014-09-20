use Inline::Perl5;

class AES256;

my $ip5 = Inline::Perl5.new();

$ip5.use('Crypt::CBC');
$ip5.use('MIME::Base64');
$ip5.use('Digest::SHA');

END {
    $ip5.DESTROY;
}

sub cbc(Str $key) {
    return $ip5.invoke('Crypt::CBC', 'new', $key, 'Crypt::Rijndael');
}

method Encrypt(Str $key, Str $data) returns Str {
    my $CBC = cbc($key);
    my $enc = $CBC.encrypt_hex($data);
    return $enc;
}

method Decrypt(Str $key, Str $data) {
    my $CBC = cbc($key);
    my $dec = $CBC.decrypt_hex($data);
    return $dec;
}

method RandomBytes(Int $len) returns Buf {
    return $ip5.invoke('Crypt::CBC', 'random_bytes', $len);
}

method sha256sum($data) {
    return $ip5.call('Digest::SHA::sha256_hex', $data);
}
