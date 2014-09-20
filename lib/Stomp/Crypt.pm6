use Inline::Perl5;

class Stomp::Crypt;

my $ip5 = Inline::Perl5.new();

$ip5.use('Crypt::CBC');
$ip5.use('MIME::Base64');
$ip5.use('Digest::SHA');

END {
    $ip5.DESTROY;
}

sub cbc(Blob $key) {
    return $ip5.invoke('Crypt::CBC', 'new', $key, 'Crypt::OpenSSL::AES');
}

method encrypt(Blob $key, $data) returns Str {
    my $CBC = cbc($key);
    my $enc = $CBC.encrypt_hex($data);
    return $enc;
}

method decrypt(Blob $key, Str $data) {
    my $CBC = cbc($key);
    my $dec = $CBC.decrypt_hex($data);
    return $dec;
}

method random-bytes(Int $len) returns Blob {
    my $r = $ip5.invoke('Crypt::CBC', 'random_bytes', $len);
    if $r !~~ Blob {
        $r .= encode;
    }
    return $r;
}

method sha256-sum($data) returns Str {
    return $ip5.call('Digest::SHA::sha256_hex', $data);
}

method base64-encode(Blob $data) returns Str {
    return $ip5.call('MIME::Base64::encode_base64', $data);
}

method base64-decode(Str $base64) returns Blob {
    my $decoded = $ip5.call('MIME::Base64::decode_base64', $base64);
    if $decoded !~~ Blob {
        $decoded .= encode;
    }
    return $decoded;
}
