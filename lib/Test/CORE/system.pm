package Test::CORE::system;
use strict;
use warnings;
our $VERSION = '2.0';

BEGIN {
    *CORE::GLOBAL::system = sub {
        require Test::CORE::system::Command;
        my $cmd;
        if (@_ == 1) {
            $cmd = Test::CORE::system::Command->new_from_string($_[0]);
        } else {
            $cmd = Test::CORE::system::Command->new_from_arrayref(\@_);
        }
        my $result = bless {}, 'Test::CORE::system::Result';
        handle_command($cmd => $result);
        return $result->return_value; # XXX
    };
    *CORE::GLOBAL::exec = sub {
        require Test::CORE::system::Command;
        my $cmd;
        if (@_ == 1) {
            $cmd = Test::CORE::system::Command->new_from_string($_[0]);
        } else {
            $cmd = Test::CORE::system::Command->new_from_arrayref(\@_);
        }
        my $result = bless {}, 'Test::CORE::system::Result';
        handle_command($cmd => $result);
        if ($result->exec_error) {
            return 1; # XXX
        } else {
            exit($result->return_value || 0);
        }
    };
}

our @CommandHandlers;

our $DefaultCommandHandler = {
    label => 'default handler',
    code => sub {
        my ($cmd, $result) = @_;
        $result->exec_error(1);
        print STDERR 'Command handler for "', $cmd->debug_info, '" not found."', "\n";
    },
};

sub register_command_handler {
    my ($class, %args) = @_;
    push @CommandHandlers, \%args;
}

sub handle_command {
    my ($cmd => $result) = @_;
    my $command = $cmd->command;
    my $selected_handler;
    if (defined $command) {
        for my $handler (@CommandHandlers) {
            if ($command =~ $handler->{pattern}) {
                $selected_handler = $handler;
            }
        }
    }
    $selected_handler ||= $DefaultCommandHandler;
    
    if ($ENV{MOREMORE_DEBUG}) {
        print STDERR 'SYSTEM: "' . $cmd->debug_info . '" is handled by "';
        print STDERR $selected_handler->{code}->{label} || $selected_handler->{code}->{pattern};
        
        print STDERR '"', "\n";
    }
    $selected_handler->{code}->($cmd => $result);
}

package Test::CORE::system::Result;

sub return_value {
    if (@_ > 1) {
        $_[0]->{return_value} = $_[1];
    }
    return $_[0]->{return_value};
}

sub exec_error {
    if (@_ > 1) {
        $_[0]->{exec_error} = $_[1];
    }
    return $_[0]->{exec_error};
}

1;
