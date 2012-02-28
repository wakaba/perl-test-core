package Test::CORE::system::Command;
use strict;
use warnings;
our $VERSION = '1.0';

sub new {
    my $class = shift;
    return bless {@_}, $class;
}

sub new_from_string {
    my ($class, $command_line) = @_;
    if ($command_line ne quotemeta $command_line) {
        return $class->new(
            command_line => $command_line,
            source => 'command_line',
        );
    } else {
        return $class->new_from_arrayref([split /\s+/, $command_line]);
    }
}

sub new_from_arrayref {
    my ($class, $args) = @_;
    my $command = shift @$args;
    return $class->new(
        command => $command,
        args => $args,
        source => 'args',
        _parsed => 1,
    );
}

sub source {
    return $_[0]->{source};
}

sub _parse_command_line {
    my $self = shift;
    my $s = $self->{command_line};

    if ($s =~ /\s*&\s*$/ and not $s =~ /(?:^|[^\\])\\(?:\\\\)*&\s*$/) {
        $s =~ s/\s*&\s*$//;
        $self->{background} = 1;
    }

    my @args;
    while ($s =~ s/((?>[^\\"\s]|\\.|"(?>[^"\\]|\\.)*")+)//s) {
        my $t = $1;
        $t =~ s/\\(.)|"((?>[^"\\]|\\.)*)"/defined $1 ? $1 : (join '', map { my $u = $_; $u =~ s!\\(.)!$1!gs; $u } $2)/ges;
        push @args, $t;
    }

    if ($s =~ /\S/) {
        @args = ();
    }

    $self->{command} = shift @args;
    $self->{args} = \@args;
}

sub command_line {
    return $_[0]->{command_line};
}

sub command {
    my $self = shift;
    $self->_parse_command_line unless $self->{_parsed};

    return $self->{command}; # or undef
}

sub args {
    my $self = shift;
    $self->_parse_command_line unless $self->{_parsed};

    return $self->{args};
}

sub background {
    my $self = shift;
    $self->_parse_command_line unless $self->{_parsed};

    return $self->{background};
}

sub debug_info {
    my $self = shift;
    if ($self->source eq 'command_line') {
        return 'Command from a string: |' . $self->{command_line} . '|';
    } else {
        return 'Command from arguments: |' . (join ' ', $self->{command}, @{$self->{args}}) . '|';
    }
}

1;
