use AES256;
use JSON::Tiny;

class Stomp;

my $prog = "Stomp";

my Str $stompDir = %*ENV<HOME> ~ "/.stomp";
my Str $stompKey = "$stompDir/keys/stompkey";

method Command(Str $command, Str @options) {
    given $command {
        when <add> { self.Add(@options) }
        when <get> { self.Get(@options) }
        when <find> { self.find(@options) }
        default { self.Usage() }
    }
}

method Add(Str @options) {
    self.Usage("must specify sitename and username") if @options.elems < 2;
    my $sitename = @options.shift;
    my $username = @options.shift;
    my $password = @options.shift // AES256.RandomBytes(16);
    my $enckey = readKey();
    my $deckey = AES256.Decrypt(getPassword(), $enckey);

    my %data =
        sitename => $sitename,
        username => $username,
        password => $password
    ;

    my $datajson = to-json(%data);

    my $filename = AES256.sha256sum(AES256.RandomBytes(16));
    my $encdata = AES256.Encrypt($deckey, $datajson);
    writeEncryptedFile($filename, $encdata);

    my $indexjson = AES256.Decrypt($deckey, readIndex());
    my $index = from-json($indexjson);
    $index{$sitename} = $filename;
    my $encindex = AES256.Encrypt($deckey, to-json($index));
    writeIndex($encindex);

    header($sitename);
    say $password;
}

method Get(Str @options) {
    my $sitename = @options.shift;
    my $enckey = readKey();
    my $deckey = AES256.Decrypt(getPassword(), $enckey);

    my $json = from-json(AES256.Decrypt($deckey, readIndex()));
    my $filename = $json{$sitename};

    my $encdata = readEncryptedFile($filename);
    my $decdata = AES256.Decrypt($deckey, $encdata);
    my $datajson = from-json($decdata);
    header($datajson<sitename>);
    say $datajson<password>;
}

method find(Str @options) {
    my $search = @options.shift;

    my $enckey = readKey();
    my $deckey = AES256.Decrypt(getPassword(), $enckey);

    my $json = from-json(AES256.Decrypt($deckey, readIndex()));

    for $json.kv -> $key, $value {
        if $key ~~ / $search  / {
            my $encdata = readEncryptedFile($value);
            my $decdata = AES256.Decrypt($deckey, $encdata);
            my $data = from-json($decdata);
            say "$key\t ({$data<username>})";;
        }
    }
}

method Setup {
    return if $stompDir.IO.d;

    if not $stompDir.IO.e {
        header("Welcome to $prog");
        msg("getting things ready...");
        xMkdir($stompDir);
        xChmod(0o700, $stompDir);
        xMkdir("$stompDir/keys");
        xMkdir("$stompDir/data");
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

method Usage(Str $proclaim?) {
    say $proclaim if $proclaim;
    say "XXX TODO";
    exit(0);
}

sub writeKey(Str $encdata) {
    my $fh = xOpen($stompKey);
    xWrite($fh, $encdata);
    
    xChmod(0o0400, $stompKey);
    xChmod(0o500, "$stompDir/keys");
}

sub readKey {
    return slurp($stompKey) or die("could not read $stompKey");
}

sub writeEncryptedFile(Str $filename, Str $data) {
    my $fh = xOpen("$stompDir/data/$filename");
    xWrite($fh, $data);
    xChmod(0o400, "$stompDir/data/$filename");
}

sub readEncryptedFile(Str $filename) {
    return xSlurp("$stompDir/data/$filename");
}

sub writeIndex(Str $encjson) {
    my $fh = xOpen("$stompDir/index");
    xWrite($fh, $encjson);
}

sub readIndex {
    return xSlurp("$stompDir/index");
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

sub xMkdir(Str $dir) {
    mkdir($dir) or panic("could not create directory $dir");
}

sub xChmod(Int $mode, Str $file) {
    chmod($mode, $file) or panic("could not set file permissions on $file");
}

sub xOpen(Str $file) {
    return open($file, :w) or panic("could not open $file");
}

sub xWrite(IO::Handle $fh, Str $text) {
    $fh.print($text) or panic("could not write to {$fh.path}");
}

sub xSlurp(Str $file) {
    return slurp($file) or panic("could not slurp $file");
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
