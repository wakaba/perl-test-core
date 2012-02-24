package test::Test::CORE::system;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
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
    eq_or_diff $last_cmd->args, ['abc'];
    ng $last_cmd->background;
    
    system $command . ' abcdef';
    isa_ok $last_cmd, 'Test::CORE::system::Command';
    is $last_cmd->command, $command;
    eq_or_diff $last_cmd->args, ['abcdef'];
    ng $last_cmd->background;
}

sub _default : Test(2) {
    my (undef, $file_name) = tempfile;
    unlink $file_name;
    ng -f $file_name;

    system 'echo 1243 > ' . $file_name;

    ng -f $file_name;
}

__PACKAGE__->runtests;

1;
