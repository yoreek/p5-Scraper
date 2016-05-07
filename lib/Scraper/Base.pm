package Scraper::Base;
use warnings;
use strict;

use constant DRV_CLASS_PREFIX => 'Scraper::Driver';
use constant LOG4PERL_CONF    => q(
    log4perl.category.main          = INFO, Screen
    log4perl.appender.Screen        = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.stderr = 1
    log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.Screen.layout.ConversionPattern = %d (%p) %F{1}:%L %M - %m%n
);

sub new {
    my ($class, @args) = @_;

    my $self = bless {
        drv       => undef,
        logger    => undef,
        log_level => 'error',
        @args,
    }, $class;

    $self->_init_logger unless $self->{logger};

    my $drv_class = join('::', DRV_CLASS_PREFIX, $self->{drv});
    eval "require $drv_class"; ## no critic (BuiltinFunctions::ProhibitStringyEval)
    if (my $err = $@) {
        $self->logger->error("Can't load module '$drv_class'");
        die "Can't load module '$drv_class'";
    }

    $self->{drv} = $drv_class->new(
        logger => $self->{logger},
    );

    return $self;
}

sub _init_logger {
    my ($self) = @_;

    require Log::Log4perl;
    Log::Log4perl::init(\LOG4PERL_CONF);
    $self->{logger} = Log::Log4perl::get_logger("main");
    $self->{logger}->level(uc $self->{log_level});

    my $old_warn_handler = $SIG{__WARN__};
    $SIG{__WARN__} = sub {
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;

        if (Log::Log4perl->initialized) {
            my @lines = map {"$_"} @_;

            $self->logger->warn(
                map { chomp; $_ } @lines
            );
        }
        elsif ($old_warn_handler) {
            # Fallback to the old handler
            goto &$old_warn_handler;
        }
        else {
            # Now handler - just carp about it for now
            local $SIG{__WARN__};
            die(@_);
        }
    };

    my $old_die_handler = $SIG{__DIE__};
    $SIG{__DIE__} = sub {
        if ($^S) {
            # We're in an eval {} and don't want log
            # this message but catch it later
            return;
        }

        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
        if (Log::Log4perl->initialized) {
            my @lines = map {"$_"} @_;

            $self->logger->error(
                map { chomp; $_ } @lines
            );
        }
        elsif ($old_die_handler) {
            # Fallback to the old handler
            goto &$old_die_handler;
        }
        else {
            # Now handler - just carp about it for now
            local $SIG{__DIE__};
            die(@_);
        }
    };
}

sub drv    { $_[0]->{drv   } }
sub logger { $_[0]->{logger} }

1;
