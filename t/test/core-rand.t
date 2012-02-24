package test::Test::CORE::rand;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Test::CORE::rand;

sub _default : Test(5) {
    my $v1 = rand;
    ok $v1 <= 1;
    ok 0 <= $v1;

    my $v2 = rand;
    ok $v2 <= 1;
    ok 0 <= $v2;
    isnt $v2, $v1;
}

sub _default_100 : Test(5) {
    my $v1 = rand 100;
    ok $v1 <= 100;
    ok 0 <= $v1;

    my $v2 = rand;
    ok $v2 <= 100;
    ok 0 <= $v2;
    isnt $v2, $v1;
}

sub _custom : Test(3) {
    local $Test::CORE::rand::RAND_CODE = sub {
        return $_[0] / 2;
    };

    my $v1 = rand 50;
    is $v1, 25;
    
    my $v2 = rand 100;
    is $v2, 50;

    my $v3 = rand;
    is $v3, 0.5;
}

__PACKAGE__->runtests;

1;
