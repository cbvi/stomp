module Stomp::Index;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Key;
use JSON::Tiny;

our sub UpdateIndex(Stomp::Key $key, Str $sitename, Str $filename) {
    my $index = from-json($key.decrypt(readIndex()));
    $index{$sitename} = $filename;
    writeIndex($key.encrypt(to-json($index)));
}

our sub GetIndex(Stomp::Key $key) {
    return from-json($key.decrypt(readIndex()));
}

our sub RemoveFromIndex(Stomp::Key $key, Str $sitename) {
    my $index = from-json($key.decrypt(readIndex()));
    $index{$sitename} :delete;
    writeIndex($key.encrypt(to-json($index)));
}

sub readIndex {
    return xslurp($Stomp::Config::Index);
}

sub writeIndex(Str $encjson) {
    my $fh = xopen($Stomp::Config::Index);
    xwrite($fh, $encjson);
    xclose($fh);
}
