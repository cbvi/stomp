use v6;
use Test;
use lib 't';
use STHelper;
use Stomp::Config;
use Stomp::Data;

set-config();

plan 1;

Stomp::Data::setup(auto => 'OxychromaticBlowfishSwatDynamite');

ok $Stomp::Config::RootDir.IO.d, 'root dir exists';

exit(0);
