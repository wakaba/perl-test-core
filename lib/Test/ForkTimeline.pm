package Test::ForkTimeline;
use strict;
use warnings;
our $VERSION = '1.0';
use Exporter::Lite;

our @EXPORT = qw(fork_timeline stop_time);

our $fake_now;
my $datetime_was_loaded;

BEGIN {
    *CORE::GLOBAL::time = sub () {
        if (defined $fake_now) {
            return $fake_now;
        } else {
            return CORE::time;
        }
    };

    if ($INC{'DateTime.pm'}) {
        $datetime_was_loaded = 1;
    }
}

sub fork_timeline (&$) {
    my ($code, $time) = @_;
    warn "fork_timeline does not affect DateTime->now unless ".__PACKAGE__." is loaded before DateTime\n"
        if $datetime_was_loaded;
    local $fake_now = $time;
    warn "fork_timeline: time ~~ unix epoch ($time) is dangerous!\n" if $time < 9*3600;
    return $code->();
}

sub stop_time () {
    $fake_now ||= CORE::time;
}

sub start_time () {
    undef $fake_now;
}

1;
