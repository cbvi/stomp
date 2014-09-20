use Stomp::Crypt;
use Stomp::Config;
use Stomp::Exception;
use JSON::Tiny;

module Stomp::Utils;

our sub Encrypt(Blob $key, $data) returns Str {
    my $hash = Stomp::Crypt.sha256sum($data);
    my $enc = Stomp::Crypt.Encrypt($key, $data);
    return "$hash\n$enc";
}

our sub Decrypt(Blob $key, Str $data) {
    my @lines = $data.lines;
    panic("data format is invalid") if @lines.elems != 2;
    my ($hash, $enc) = @lines;
    my $dec = Stomp::Crypt.Decrypt($key, $enc);
    if $hash ne Stomp::Crypt.sha256sum($dec) {
        err("Decryption failed");
    }
    return $dec;
}

our sub Random(Int $length) returns Blob {
    return Stomp::Crypt.RandomBytes($length);
}

our sub Sha256($data) {
    return Stomp::Crypt.sha256sum($data);
}

our sub Base64Encode(Blob $data) {
    return Stomp::Crypt.encode_base64($data);
}

our sub Base64Decode(Str $base64) {
    return Stomp::Crypt.decode_base64($base64);
}

our sub GeneratePassword(Int $len, Bool :$special?) returns Str {
    my $achars = / [ <[a..z]> | <[A..Z]> | <[0..9]> ] /;
    my $sym = !$special ?? $achars !! / [<$achars>|'~'|'`'|'!'|'@'|'#'|'$'|'%'|'^'|'&'|'*'|'('|')'|'-'|'_'|'+'|'='|'<'|'>'|','|'.'|'?'|'/'|':'|';'] /;

    my Str $gen = '';

    while ($gen.chars < $len) {
        my Blob $bin = Random(1);
        # decode as utf8 and ignore any malformed utf8 exceptions
        try {
            my $s = $bin.decode('utf8');
            $gen ~= $s.comb( / <$sym> /).join();
        }
    }
    return $gen;
}

our sub DoRequest(Str $data, Bool :$noreply?) {
    my $sock;
    try {
        $sock = IO::Socket::INET.new( host => $Stomp::Config::Host,
            port => $Stomp::Config::Port);
        CATCH { err("could not connect, is the daemon running?"); }
    }
    $sock.send($data ~ "\n");

    my $response = '';
    loop {
        my $r = $sock.recv(1);
        last if $r eq "";
        $response ~= $r;
    }
    $sock.close();
    return !$noreply ?? from-json($response) !! from-json('{ }');
}

our sub PrepareRequest(Str $command, *%params) {
    my %r = :$command;
    for %params.kv -> $name, $value {
        %r{$name} = $value;
    }
    return to-json(%r);
}

our sub IsSetup() {
    return $Stomp::Config::RootDir.IO.d;
}

sub AskPassword(Str $prompt = "Master password: ", Bool :$confirm?) is export {
    my Str $p1 = "";
    my Str $p2 = "";
    loop {
        $p1 = prompt($prompt);
        return $p1 if not $confirm;
        return $p1 if $p1 eq prompt("Confirm: ");
        msg("Passwords did not match, try again");
    }
}

sub xMkdir(Str $dir) is export {
    mkdir($dir);
    CATCH { panic("could not create directory $dir"); }
}

sub xChmod(Int $mode, Str $file) is export {
    chmod($mode, $file);
    CATCH { panic("could not set file permissions on $file"); }
}

sub xOpen(Str $file) returns IO::Handle is export {
    return open($file, :w);
    CATCH { panic("could not open $file"); }
}

sub xWrite(IO::Handle $fh, Str $text) is export {
    $fh.print($text);
    CATCH { panic("could not write to {$fh.path}"); }
}

sub xClose(IO::Handle $fh) is export {
    $fh.close();
}

sub xSlurp(Str $file) is export {
    return slurp($file); 
    CATCH { panic("could not slurp $file"); }
}

sub xUnlink(Str $file) is export {
    unlink($file);
    CATCH { panic("could not delete $file"); }
}

our sub AskYesOrNo(Str $question, Bool :$yes?, Bool :$no?) returns Bool {
    panic("must specify a default") if not $yes and not $no;
    panic("both yes and no cannot be the default") if $yes and $no;
    my $default = $yes ?? "Y" !! "N";
    my $other = $yes ?? "n" !! "y";
    my $input = prompt("$question [$other/$default]: ");
    $input = $default if $input eq "";
    $input .= uc;
    $input .= substr(0, 1);
    if $input ne any('Y', 'N') {
        msg("answer (Y)es or (N)o");
        return AskYesOrNo($question, :$yes, :$no);
    }
    return False if $input eq 'N';
    return True if $input eq 'Y';
}

sub header(Str $hdr) is export {
    say "=== $hdr ===";
}

sub msg(Str $m) is export {
    say "==> $m";
}

sub err(Str $e) is export {
    my $message = "==> $e";
    Stomp::Exception.new(:$message).throw;
}

sub panic(Str $err) is export {
    my $retort = "# this is a fatal error, abandoning ship.";
    say "# $err";
    die $retort;
}
