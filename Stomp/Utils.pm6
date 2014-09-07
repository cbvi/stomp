use AES256;

module Stomp::Utils;

our sub encrypt(Str $key, Str $data) returns Str {
    return AES256.Encrypt($key, $data);
}

our sub decrypt(Str $key, Str $data) returns Str {
    return AES256.Decrypt($key, $data);
}

our sub random(Int $length) {
    return AES256.RandomBytes($length);
}

our sub sha256(Str $data) {
    return AES256.sha256sum($data);
}

our sub generatePassword(Int $len, Bool :$special?) returns Str {
    my $achars = / [ <[a..z]> | <[A..Z]> | <[0..9]> ] /;
    my $sym = !$special ?? $achars !! / [<$achars>|'~'|'`'|'!'|'@'|'#'|'$'|'%'|'^'|'&'|'*'|'('|')'|'-'|'_'|'+'|'='|'<'|'>'|','|'.'|'?'|'/'|':'|';'] /;

    my Str $gen = '';

    my $ur = open('/dev/urandom');

    while ($gen.chars < $len) {
         my $bin = $ur.read(1);
        my $s = $bin.list.fmt("%c", '');
        $gen ~= $s.comb( / <$sym> /).join();
    }
    $ur.close();
    return $gen;
}

sub askPassword(Bool :$confirm?) is export {
    my Str $p1 = "";
    my Str $p2 = "";
    loop {
        $p1 = prompt("Master password: ");
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

our sub askYesOrNo(Str $question, Bool :$yes?, Bool :$no?) returns Bool {
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
        return askYesOrNo($question, :$yes, :$no);
    }
    return False if $input eq 'N';
    return True if $input eq 'Y';
}

our sub header(Str $hdr) {
    say "=== $hdr ===";
}

our sub msg(Str $m) {
    say "==> $m";
}

our sub err(Str $e) {
    msg($e);
    exit(1);
}

our sub panic(Str $err) {
    my $retort = "# this is a fatal error, abandoning ship.";
    my Int $len = ($retort.chars, "# $err".chars).max;
    $len = 76 if $len > 76;
    print ' ' xx 4;
    print "#" xx $len;
    say '';
    print ' ' xx 4;
    say "# $err";
    print ' ' xx 4;
    say $retort;
    exit(1);
}
