module Stomp::Index;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Key;
use JSON::Tiny;

our sub UpdateIndex(Stomp::Key $key, Str $sitename, Str $filename) {
    my $index = from-json($key.Decrypt(readIndex()));
    $index{$sitename} = $filename;
    writeIndex($key.Encrypt(to-json($index)));
}

our sub GetIndex(Stomp::Key $key) {
    return from-json($key.Decrypt(readIndex()));
}

our sub RemoveFromIndex(Stomp::Key $key, Str $sitename) {
    my $index = from-json($key.Decrypt(readIndex()));
    $index{$sitename} :delete;
    writeIndex($key.Encrypt(to-json($index)));
}

sub readIndex {
    return xslurp($Stomp::Config::Index);
}

sub writeIndex(Str $encjson) {
    my $fh = xopen($Stomp::Config::Index);
    xwrite($fh, $encjson);
    xclose($fh);
}
