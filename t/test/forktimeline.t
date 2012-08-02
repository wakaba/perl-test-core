package test::Test::ForkTimeline;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::ForkTimeline;
use Test::MoreMore;
use DateTime;

sub _default_now : Test(2) {
    ok +time > DateTime->new(year => 2010, month => 1, day => 1)->epoch;
    is +DateTime->now->epoch, time;
}

sub _fork_timeline : Test(4) {
    fork_timeline {
        my $time = time;
        is $time, DateTime->new(year => 1980, month => 2, day => 3)->epoch;
        is +DateTime->now->epoch, $time;
    } DateTime->new(year => 1980, month => 2, day => 3)->epoch;

    ok +time > DateTime->new(year => 2010, month => 1, day => 1)->epoch;
    is +DateTime->now->epoch, time;
}

sub _nested_fork_timeline : Test(6) {
    fork_timeline {
        my $time = time;
        is $time, DateTime->new(year => 1980, month => 2, day => 3)->epoch;
        is +DateTime->now->epoch, $time;

        fork_timeline {
            my $time = time;
            is $time, DateTime->new(year => 2020, month => 2, day => 3)->epoch;
            is +DateTime->now->epoch, $time;
        } DateTime->new(year => 2020, month => 2, day => 3)->epoch;
    } DateTime->new(year => 1980, month => 2, day => 3)->epoch;

    ok +time > DateTime->new(year => 2010, month => 1, day => 1)->epoch;
    is +DateTime->now->epoch, time;
}

sub _fork_timeline_return : Test(1) {
    my $v = fork_timeline {
        123;
    } 100000;
    is $v, 123;
}

sub _stop_time_normal : Test(3) {
    my $time1 = time;
    stop_time;
    my $time2 = time;
    is $time2, $time1;
    Test::ForkTimeline::start_time;
    my $time3 = time;
    is $time3, CORE::time;
    sleep 1;
    my $time4 = time;
    is $time4, $time3 + 1;
}

sub _stop_time_fork_timeline : Test(3) {
    my $time1 = 3000000;
    fork_timeline {
        my $time2 = time;
        is $time2, $time1;
        sleep 1;
        my $time3 = time;
        is $time3, $time1;

        stop_time;
        sleep 1;

        my $time4 = time;
        is $time4, $time1;
    } $time1;
}

__PACKAGE__->runtests;

1;
