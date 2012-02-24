package test::Test::CORE::system::Command;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Test::CORE::system::Command;

sub _parse : Test(40) {
    for (
        {input => undef, command => undef, args => [], background => undef, source => 'args'},
        {input => '', command => undef, args => [], background => undef, source => 'args'},
        {input => 'echo', command => 'echo', args => [], background => undef, source => 'args'},
        {input => 'echo&', command => 'echo', args => [], background => 1, source => 'command_line'},
        {input => 'echo &', command => 'echo', args => [], background => 1, source => 'command_line'},
        {input => 'echo  & ', command => 'echo', args => [], background => 1, source => 'command_line'},
        {input => 'perl -e "foo bar baz" Q&', command => 'perl', args => ['-e', 'foo bar baz', 'Q'], background => 1, source => 'command_line'},
        {input => 'perl -e "foo bar baz" Q\\&', command => 'perl', args => ['-e', 'foo bar baz', 'Q&'], background => undef, source => 'command_line'},
        {input => 'perl -e "foo bar baz" Q\\\\&', command => 'perl', args => ['-e', 'foo bar baz', 'Q\\'], background => 1, source => 'command_line'},
        {input => 'perl -e "foo bar baz" Q\\\\\\&', command => 'perl', args => ['-e', 'foo bar baz', 'Q\\&'], background => undef, source => 'command_line'},
    ) {
        my $input = delete $_->{input};
        my $cmd = Test::CORE::system::Command->new_from_string($input);
        for my $method (keys %$_) {
            eq_or_diff $cmd->$method, $_->{$method}, '_parse ' . $input;
        }
    }
}

sub _args : Test(8) {
    for (
        {input => [''], command => '', args => [], background => undef, source => 'args'},
        {input => ['echo', 'a', 'Q&A'], command => 'echo', args => ['a', 'Q&A'], background => undef, source => 'args'},
    ) {
        my $input = delete $_->{input};
        my $cmd = Test::CORE::system::Command->new_from_arrayref($input);
        for my $method (keys %$_) {
            eq_or_diff $cmd->$method, $_->{$method};
        }
    }
}

__PACKAGE__->runtests;

1;
