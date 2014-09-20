use Test;
use Stomp::Utils;

plan 8;

my $key = "Frumious Bandersnatch!".encode;
my $data = "\"Beware the Jabberwock, my son!\nThe jaws that bite, the claws that catch!'";

my $enc = Stomp::Utils::encrypt($key, $data);

is Stomp::Utils::decrypt($key, $enc), $data, 'encrypted data decrypts back';
ok Stomp::Utils::random(16), 'random works';
is Stomp::Utils::random(32).bytes, 32, 'random length is correct';
is Stomp::Utils::random(32).decode('latin-1').chars, 32, 'random chars correct';
is Stomp::Utils::sha256('Jubjub bird'), '41ea3dfbb3ba7729ec98ada8db14cd0f03e6e3688d6f812a614d64ef39d9f73a', 'sha sum is correct';

is Stomp::Utils::generate-password(32).chars, 32, 'generate password works';
ok Stomp::Utils::generate-password(1024,:special).index(any('?', '$', '!')), 'special chars';

is Stomp::Utils::prepare-request("seekmanxomefoe", jabberwocky => 'eyes of flame', bandersnatch => 'frumious'), '{ "command" : "seekmanxomefoe", "jabberwocky" : "eyes of flame", "bandersnatch" : "frumious" }', 'prepare request works';

done();
