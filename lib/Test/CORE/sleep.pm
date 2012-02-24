package Test::CORE::sleep;
use strict;
use warnings;
our $VERSION = '1.0';

our $DisableSleep;

BEGIN {
    *CORE::GLOBAL::sleep = sub ($) {
        my $s = shift;
        if ($DisableSleep) {
            warn "SLEEP " . $s, "\n";
        } else {
            CORE::sleep($s);
        }
    };
}

1;
