
use strict;
use warnings;

use Test::More;

my @modules = qw(
    Scraper
    Scraper::Base
    Scraper::DataCom
    Scraper::Driver::Base
    Scraper::Driver::WebKit
);

plan tests => scalar @modules;


use_ok($_) for @modules;
