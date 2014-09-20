use Inline::Perl5;

class AES256;

my $ip5 = Inline::Perl5.new();

$ip5.use('Crypt::CBC');
$ip5.use('MIME::Base64');
$ip5.use('Digest::SHA');

END {
    $ip5.DESTROY;
}

sub cbc(Blob $key) {
    return $ip5.invoke('Crypt::CBC', 'new', $key, 'Crypt::Rijndael');
}

method Encrypt(Blob $key, $data) returns Str {
    my $CBC = cbc($key);
    my $enc = $CBC.encrypt_hex($data);
    return $enc;
}

method Decrypt(Blob $key, Str $data) {
    my $CBC = cbc($key);
    my $dec = $CBC.decrypt_hex($data);
    return $dec;
}

method RandomBytes(Int $len) returns Buf {
    return $ip5.invoke('Crypt::CBC', 'random_bytes', $len);
}

method sha256sum($data) returns Str {
    return $ip5.call('Digest::SHA::sha256_hex', $data);
}

method encode_base64(Blob $data) returns Str {
    return $ip5.call('MIME::Base64::encode_base64', $data);
}

method decode_base64(Str $base64) returns Blob {
    my $decoded = $ip5.call('MIME::Base64::decode_base64', $base64);
    if $decoded !~~ Blob {
        $decoded .= encode;
    }
    return $decoded;
}
