use Test;
use AES256;

my $key = "Jabberwocky".encode;
my $data = "'Twas brillig, and the slithy toves\nDid gyre and gimble in the wabe;\nAll mimsy were the borogoves,\nAnd the mome raths outgrabe.";

my $enc = AES256.Encrypt($key, $data);

is AES256.Decrypt($key, $enc), $data, 'encrypted data decrypts back';
ok AES256.RandomBytes(16), 'random bytes works';
is AES256.sha256sum($key), 'cf4debebaedc20e5c1b167823652bb026c7a8cb70ac0ba9fc27d839c9689306c', 'sha sum is correct';

done();
