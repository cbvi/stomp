use Test;
use Stomp::Utils;

plan 6;

my $key = "Frumious Bandersnatch!";
my $data = "\"Beware the Jabberwock, my son!\nThe jaws that bite, the claws that catch!'";

my $enc = Stomp::Utils::Encrypt($key, $data);

is Stomp::Utils::Decrypt($key, $enc), $data, 'encrypted data decrypts back';
ok Stomp::Utils::Random(16), 'random works';
is Stomp::Utils::Sha256('Jubjub bird'), '41ea3dfbb3ba7729ec98ada8db14cd0f03e6e3688d6f812a614d64ef39d9f73a', 'sha sum is correct';

is Stomp::Utils::GeneratePassword(32).chars, 32, 'generate password works';
ok Stomp::Utils::GeneratePassword(1024, :special).index('?'), 'special chars';

is Stomp::Utils::PrepareRequest("seekmanxomefoe", jabberwocky => 'eyes of flame', bandersnatch => 'frumious'), '{ "command" : "seekmanxomefoe", "jabberwocky" : "eyes of flame", "bandersnatch" : "frumious" }', 'prepare request works';

done();
