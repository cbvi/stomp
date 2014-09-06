use AES256;
use JSON::Tiny;

class Stomp;

my $prog = "Stomp";

my IO::Path $stompDir .= new(%*ENV<HOME> ~ "/.stomp");
my Str $stompKey = "$stompDir/keys/stompkey";

method Command(Str $command, Str @options) {
    given $command {
        when <add> { self.Add(@options) }
        when <get> { self.Get(@options) }
        default { self.Usage() }
    }
}

method Add(Str @options) {
    my $sitename = @options.shift;
    my $enckey = readKey();
    my $deckey = AES256.Decrypt(getPassword(), $enckey);
    my $data = "Sitename: $sitename";
    my $filename = AES256.sha256sum(AES256.RandomBytes(16));
    my $encdata = AES256.Encrypt($deckey, $data);
    writeEncryptedFile($filename, $encdata);

    my $json = AES256.Decrypt($deckey, readIndex());
    my $index = from-json($json);
    $index{$sitename} = $filename;
    my $encjson = AES256.Encrypt($deckey, to-json($index));
    writeIndex($encjson);
}

method Get(Str @options) {
    my $sitename = @options.shift;
    my $enckey = readKey();
    my $deckey = AES256.Decrypt(getPassword(), $enckey);
    my $filename = hashFilename($sitename, $deckey);
    my $encdata = readEncryptedFile($filename);
    my $decdata = AES256.Decrypt($deckey, $encdata);
    say $decdata;
}

method Setup {
    return if $stompDir.d;

    if not $stompDir.e {
        header("Welcome to $prog");
        msg("getting things ready...");
        mkdir($stompDir)
            or panic("could not create $stompDir");
        chmod(0o700, $stompDir)
            or panic("could not set permissions on $stompDir");
        mkdir("$stompDir/keys")
            or panic("could not create $stompDir/keys");
        mkdir("$stompDir/data")
            or panic("could not create $stompDir/data");
        msg("Let's begin");

        {
            my $pw = getPassword(:confirm);
            my $key = AES256.RandomBytes(1024 * 8);
            writeKey(AES256.Encrypt($pw, $key));
            my $encjson = AES256.Encrypt($key, to-json({ }));
            writeIndex($encjson);
        }

        msg("All done. You can now use $prog. Have fun.");
        exit(0);
    }
}

method Usage() {
    say "XXX TODO";
    exit(0);
}

sub writeKey(Str $encdata) {
    my $fh = open($stompKey, :w)
        or panic("cannot open $stompKey for writing");
    $fh.print($encdata) or panic("could not write data to $stompKey");
    
    chmod(0o0400, $stompKey)
        or panic("could not set file permissions on $stompKey");
    chmod(0o500, "$stompDir/keys")
        or panic("could not permissions on $stompDir/keys");
}

sub readKey {
    return slurp($stompKey) or die("could not read $stompKey");
}

sub writeEncryptedFile(Str $filename, Str $data) {
    my $fh = open("$stompDir/data/$filename", :w);
    $fh.print($data);
    chmod(0o400, "$stompDir/data/$filename");
}

sub readEncryptedFile(Str $filename) {
    return slurp("$stompDir/data/$filename");
}

sub writeIndex(Str $encjson) {
    my $fh = open("$stompDir/index", :w);
    $fh.print($encjson);
}

sub readIndex {
    return slurp("$stompDir/index");
}

sub hashFilename(Str $filename, Str $key) {
    return AES256.sha256sum($filename ~ $key);
}

sub getPassword(Bool :$confirm?) {
    my Str $p1 = "";
    my Str $p2 = "";
    while ($p1 eq "" || ($confirm && $p1 ne $p2)) {
        $p1 = prompt("Password: ");
        return $p1 if not $confirm;
        return $p1 if $p1 eq prompt("Confirm: ");
        msg("Passwords did not match, try again");
    }
}

sub header(Str $hdr) {
    say "=== $hdr ===";
}

sub msg(Str $m) {
    say "==> $m";
}

sub panic(Str $err) {
    say "#" xx 72;
    say "# $err";
    exit(1);
}
