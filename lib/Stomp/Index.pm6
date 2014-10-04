module Stomp::Index;

use Stomp::Config;
use Stomp::Utils;
use Stomp::Key;
use JSON::Tiny;

our sub update(Stomp::Key $key, Str $sitename, Str $filename) {
    my $index = from-json($key.decrypt(read()));
    $index{$sitename.lc} = $filename;
    write($key.encrypt(to-json($index)));
}

our sub get(Stomp::Key $key) {
    return from-json($key.decrypt(read()));
}

our sub remove(Stomp::Key $key, Str $sitename) {
    my $index = from-json($key.decrypt(read()));
    $index{$sitename.lc} :delete;
    write($key.encrypt(to-json($index)));
}

sub read {
    return xslurp($Stomp::Config::Index);
}

sub write(Str $encjson) {
    my $fh = xopen($Stomp::Config::Index);
    xwrite($fh, $encjson);
    xclose($fh);
}
