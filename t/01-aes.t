use Test;
use Stomp::Crypt;

my $key = "Jabberwocky".encode;
my $data = "'Twas brillig, and the slithy toves\nDid gyre and gimble in the wabe;\nAll mimsy were the borogoves,\nAnd the mome raths outgrabe.";

my $enc = Stomp::Crypt.Encrypt($key, $data);

is Stomp::Crypt.Decrypt($key, $enc), $data, 'encrypted data decrypts back';
ok Stomp::Crypt.RandomBytes(16), 'random bytes works';
is Stomp::Crypt.sha256sum($key), 'cf4debebaedc20e5c1b167823652bb026c7a8cb70ac0ba9fc27d839c9689306c', 'sha sum is correct';

done();
