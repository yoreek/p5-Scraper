#!/usr/bin/perl

use warnings;
use strict;
use FindBin qw($Bin);
use lib ("$Bin/../lib");
use Getopt::Long qw(:config posix_default no_ignore_case);
use Pod::Usage;
use Scraper::DataCom;

use constant SCRAPER_DRIVER => 'WebKit';

my ($keywords, $opts) = parse_opts();

my $datacom = Scraper::DataCom->new(
    drv       => SCRAPER_DRIVER,
    log_level => ($opts->{debug} ? 'debug' : 'error'),
    username  => $opts->{username},
    password  => $opts->{password},
);

my $results = $datacom->findContacts($keywords, $opts);
if ($results) {
    print $results;
}
else {
    print "No results";
}

sub parse_opts {
    my %opts = (
        countries    => undef,
        page_size    => 200,
        username     => undef,
        password     => undef,
        debug        => 0,
    );

    GetOptions(\%opts, qw(
        country=s
        page_size=i
        username|u=s
        password|p=s
        debug
    )) or pod2usage(1);

    my @keywords = @ARGV;
    pod2usage(1) unless scalar @keywords;

    unless ($opts{username}) {
        print "Option 'username' is required\n";
        pod2usage(1);
    }
    unless ($opts{password}) {
        print "Option 'password' is required\n";
        pod2usage(1);
    }

    return (join(' ', @keywords), \%opts);
}

__END__

=head1 NAME

datacom.pl

=head1 SYNOPSIS

datacom.pl [options] <keywords>

=head1 OPTIONS

=over 8

=item B<--country <country>>

Country (default: All).

=item B<--page_size <page_size>>

Page size 25, 50, 100, 150, 200 (default: 200).

=item B<--username|-u <username>>

Username (Required).

=item B<--password|-p <password>>

Password (Required).

=item B<--debug>

Enable debug mode.

=back

=head1 DESCRIPTION

=cut
