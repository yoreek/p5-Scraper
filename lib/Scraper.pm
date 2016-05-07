package Scraper;

use strict;
use warnings;

our $VERSION = '1.00';

1;
__END__
=head1 NAME

Scraper - Framework for scraping web site data

=head1 SYNOPSIS

    use warnings;
    use strict;
    use Scraper::DataCom;

    my $datacom = Scraper::DataCom->new(
        drv       => 'WebKit',
        log_level => 'info',
        username  => 'username',
        password  => 'password',
    );

    my $results = $datacom->findContacts('marketing');
    if ($results) {
        print $results;
    }
    else {
        print "No results";
    }

=head1 DESCRIPTION

Description

=head1 AUTHOR

Yuriy Ustushenko, E<lt>yoreek@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 Yuriy Ustushenko

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
