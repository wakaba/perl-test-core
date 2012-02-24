package Test::CORE::rand;
use strict;
use warnings;
our $VERSION = '1.0';

BEGIN {
    our $RAND_CODE ||= sub ($) { CORE::rand $_[0] };

    *CORE::GLOBAL::rand = sub (;$) {
        return $RAND_CODE->($_[0] || 1);
    };
}

1;
