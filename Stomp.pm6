use AES256;

class Stomp;

my $prog = "Stomp";

my IO::Path $stompDir .= new(%*ENV<HOME> ~ "/.stomp");
my Str $stompKey = "$stompDir/keys/stompkey";

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
        msg("Let's begin");

        {
            writeKey(AES256.Encrypt(
                getPassword(:confirm), AES256.RandomBytes(1024 * 8)));
        }

        msg("All done. You can now use $prog. Have fun.");
        
    }
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

sub readkey {
    return slurp($stompKey) or die("could not read $stompKey");
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
