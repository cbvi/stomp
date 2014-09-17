use Inline::Perl5;

class AES256;

my $ip5 = Inline::Perl5.new();

$ip5.use('Crypt::CBC');
$ip5.use('MIME::Base64');
$ip5.use('Digest::SHA qw(sha256_hex)');

my Str $sub_randombytes = '
    sub randombytes {
        my $len = shift;
        return encode_base64( Crypt::CBC->random_bytes($len) );
    }';

my Str $sub_sha256sum = '
    sub sha256sum {
        my $data = shift;
        return sha256_hex($data);
    }';

$ip5.run($sub_randombytes);
$ip5.run($sub_sha256sum);

$ip5.run("\n\n1;");

END {
    $ip5.DESTROY;
}

sub cbc(Str $key) {
    return $ip5.invoke('Crypt::CBC', 'new', $key, 'Crypt::Rijndael');
}

method Encrypt(Str $key, Str $data) returns Str {
    my $CBC = cbc($key);
    my $enc = $CBC.encrypt_hex($data);
    try { $CBC.finish(); }
    return $enc;
}

method Decrypt(Str $key, Str $data) returns Str {
    my $CBC = cbc($key);
    my $dec = $CBC.decrypt_hex($data);
    try { $CBC.finish(); }
    return $dec;
}

method RandomBytes(Int $len) {
    return $ip5.call('main::randombytes', $len);
}

method sha256sum(Str $data) {
    return $ip5.call('main::sha256sum', $data);
}
