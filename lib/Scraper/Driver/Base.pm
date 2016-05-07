package Scraper::Driver::Base;
use warnings;
use strict;

use constant DEF_TIMEOUT => 60;

our $AUTOLOAD;

sub new {
    my ($class, @args) = @_;

    my $self = bless {
        real_drv => undef,
        timeout  => DEF_TIMEOUT,
        logger   => undef,
        @args,
    }, $class;

    die "Logger is not defined"
        unless $self->{logger};

    return $self;
}

sub logger { $_[0]->{logger} }

sub AUTOLOAD {
    my $name = $AUTOLOAD;
    $name =~ s/.*:://;

    my $sub = sub {
        my ($self, @args) = @_;
        return $self->{real_drv}->$name(@args);
    };

    no strict 'refs'; ## no critic
    *{$AUTOLOAD} = $sub;
    goto &$sub;
}

sub open {
    my ($self, $url) = @_;

    $self->logger->debug("Try to load url: $url");

    eval {
        local $SIG{ALRM} = sub { die "Timeout" };
        alarm $self->{timeout};
        $self->{real_drv}->open($url);
        alarm 0;
    };

    die "Failed to load url: $url due: $@" if $@;
}

1;
