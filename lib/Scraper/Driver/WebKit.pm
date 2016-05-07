package Scraper::Driver::WebKit;
use warnings;
use strict;
use WWW::WebKit;
use Time::HiRes qw(time usleep);
use parent 'Scraper::Driver::Base';

use constant DEF_TIMEOUT => 30;

sub new {
    my ($class, @args) = @_;

    my %args = (
        timeout => DEF_TIMEOUT,
        @args,
    );

    my $webkit = WWW::WebKit->new(xvfb => 1);
    $webkit->init();
    $webkit->set_timeout($args{timeout} * 1000);

    my $self = $class->SUPER::new(
        real_drv => $webkit,
        timeout  => $args{timeout},
        @args,
    );

    return $self;
}

sub wait_for_condition {
    my ($self, $condition, $timeout, $sleep) = @_;

    $timeout ||= $self->default_timeout;
    $sleep   ||= 10;

    my $expiry = time + $timeout / 1000;

    my $result;
    until ($result = $condition->()) {
        $self->process_events;

        return 0 if time > $expiry;
        usleep($sleep * 1000);
    }

    return $result;
}

sub wait_for_pending_requests {
    my ($self, $timeout, $sleep) = @_;

    return $self->wait_for_condition(sub {
        $self->pending == 0;
    }, $timeout, $sleep);
}

1;
