module Stomp::Config;

our $RootDir    = %*ENV<HOME> ~ '/.stomp';
our $KeyDir     = $RootDir ~ '/keys';
our $DataDir    = $RootDir ~ '/data';
our $Index      = $RootDir ~ '/index';
our $Key        = $KeyDir ~ '/stompkey';
