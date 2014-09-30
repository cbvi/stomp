use v6;
use Test;
use Inline::Perl5;

plan 5;

my $p5 = Inline::Perl5.new();

sub check(Str $module) {
    return $p5.run('eval { require ' ~ $module ~ '; 1 };');
}

sub avail(Str $module) {
    my $installed = check($module);
    if not $installed {
        $*ERR.say();
        $*ERR.print("#") xx 72;
        note("\n\n\tPerl 5 module $module must be installed\n");
        $*ERR.print("#") xx 72;
        $*ERR.say();
    }
    ok $installed, "Perl 5 module $module is available";
}

nok check("Hopefully::Not::A::Real::Module"), 'check method is sane';
avail("Crypt::CBC");
avail("MIME::Base64");
avail("Digest::SHA");
avail("Crypt::OpenSSL::AES");

done();

# vim: ft=perl6
