package test::Test::CORE::system;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Test::More;
use Test::CORE::system;
use File::Temp qw(tempfile);

sub _register : Test(9) {
    my $command = rand;
    my $last_cmd;
    Test::CORE::system->register_command_handler(
        pattern => qr/\Q$command\E/,
        code => sub {
            $last_cmd = shift;
        },
    );

    is $last_cmd, undef;

    system $command, 'abc';
    isa_ok $last_cmd, 'Test::CORE::system::Command';
    is $last_cmd->command, $command;
    is_deeply $last_cmd->args, ['abc'];
    ok(not $last_cmd->background);

    system $command . ' abcdef';
    isa_ok $last_cmd, 'Test::CORE::system::Command';
    is $last_cmd->command, $command;
    is_deeply $last_cmd->args, ['abcdef'];
    ok(not $last_cmd->background);
}

sub _register_allowed_command : Test(6) {
    my $command = 'echo';

    # not registered
    my $result = system $command, 'abc';
    is $result, undef;
    $result = system "$command abc";
    is $result, undef;

    Test::CORE::system->register_allowed_command(
        pattern => qr{\Q$command\E},
    );

    # registered
    $result = system $command, 'abc';
    is $result, 0;
    $result = system "$command abc";
    is $result, 0;

    # not registered
    $result = system 'ls', '.';
    is $result, undef;
    $result = system 'ls .';
    is $result, undef;
}

sub _default : Test(2) {
    my (undef, $file_name) = tempfile;
    unlink $file_name;
    ok(not -f $file_name);

    system 'echo 1243 > ' . $file_name;

    ok(not -f $file_name);
}

__PACKAGE__->runtests;

1;
