package test::Test::CORE::sleep;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::More;
use Test::Interval;
use Test::CORE::sleep;

sub _enabled : Test(2) {
    my $time1 = time;
    ms_ok {
        sleep 1;
    } 1500;
    my $time2 = time;
    isnt $time2, $time1;
}

sub _disabled : Test(1) {
    local $Test::CORE::sleep::DisableSleep = 1;
    ms_ok {
        sleep 1;
    } 500;
}

__PACKAGE__->runtests;

1;
