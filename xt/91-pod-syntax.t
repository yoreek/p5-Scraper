# test sources for POD syntax

use strict;
use warnings;

use Test::More;

# Skip if doing a regular install
plan skip_all => "Author tests not required for installation"
	unless $ENV{AUTHOR_TESTING};

eval 'use Test::Pod 1.22';  ## no critic
plan skip_all => 'Test::Pod (>=1.22) is required' if $@;

all_pod_files_ok(qw/ lib t /);
