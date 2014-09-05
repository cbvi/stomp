use Inline::Perl5;

class AES256;

my $ip5 = p5_init_perl();

$ip5.run('use strict; use warnings;');
$ip5.run('use Crypt::CBC; use MIME::Base64;');

my Str $sub_encrypt = '
    sub encrypt {
        my ($key, $data) = @_;
        my $c = Crypt::CBC->new(
            -key        => $key,
            -cipher     => "Crypt::Rijndael",
            -keysize    => 32
        );
        my $enc = encode_base64($c->encrypt($data));
        $c->finish();
        return $enc;
    }';

my Str $sub_decrypt = '
    sub decrypt {
        my ($key, $data) = @_;
        my $c = Crypt::CBC->new(
            -key        => $key,
            -cipher     => "Crypt::Rijndael",
            -keysize    => 32
        );
        my $dec = $c->decrypt(decode_base64($data));
        $c->finish();
        return $dec;
    }';

my Str $sub_randombytes = '
    sub randombytes {
        my $len = shift;
        return encode_base64( Crypt::CBC->random_bytes($len) );
    }';

$ip5.run($sub_encrypt);
$ip5.run($sub_decrypt);
$ip5.run($sub_randombytes);

method Encrypt(Str $key, Str $data) returns Str {
    return $ip5.call('main::encrypt', $key, $data);
}

method Decrypt(Str $key, Str $data) returns Str {
    return $ip5.call('main::decrypt', $key, $data);
}

method RandomBytes(Int $len) {
    return $ip5.call('main::randombytes', $len);
}
