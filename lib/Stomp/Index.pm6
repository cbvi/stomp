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
    return $key.Decrypt(readIndex());
}

sub readIndex {
    return xSlurp($Stomp::Config::Index);
}

sub writeIndex(Str $encjson) {
    my $fh = xOpen($Stomp::Config::Index);
    xWrite($fh, $encjson);
    xClose($fh);
}
