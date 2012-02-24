package test::Test::CORE::exec;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Test::CORE::exec;
use File::Temp qw(tempfile);
use POSIX;

sub fork_and_exec (@) {
    my $pid = fork();
    return -1 unless defined $pid;

    if ($pid != 0) {
        waitpid $pid, 0;
        return $?;
    } else {
        exec @_;
        exit 255;
    }
}

sub _register : Test(1) {
    my $command = rand;
    #my $last_cmd;
    Test::CORE::exec->register_command_handler(
        pattern => qr/\Q$command\E/,
        code => sub {
            #$last_cmd = shift;
            return 0;
        },
    );

    #is $last_cmd, undef;
    
    fork_and_exec $command, 'abc';
    #isa_ok $last_cmd, 'Test::CORE::system::Command';
    #is $last_cmd->command, $command;
    #eq_or_diff $last_cmd->args, ['abc'];
    #ng $last_cmd->background;
    
    fork_and_exec $command . ' abcdef';
    #isa_ok $last_cmd, 'Test::CORE::system::Command';
    #is $last_cmd->command, $command;
    #eq_or_diff $last_cmd->args, ['abcdef'];
    #ng $last_cmd->background;

    ok 1;
}

sub _default : Test(2) {
    my (undef, $file_name) = tempfile;
    unlink $file_name;
    ng -f $file_name;

    fork_and_exec 'echo 1243 > ' . $file_name;

    ng -f $file_name;
}

__PACKAGE__->runtests;

1;
