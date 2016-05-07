# test for recommendations from "Perl Best Practices"

use strict;
use warnings;

use Test::More;

# Skip if doing a regular install
plan skip_all => "Author tests not required for installation"
	unless $ENV{AUTHOR_TESTING};

eval 'use Test::Perl::Critic'; ## no critic
plan skip_all => 'Test::Perl::Critic required' if $@;

# check only new code
my @dirs = qw( lib/Scraper );
my @files = glob('t/*.t');

push @files, Perl::Critic::Utils::all_perl_files(@dirs);

plan tests => scalar(@files);
critic_ok($_) foreach @files;
