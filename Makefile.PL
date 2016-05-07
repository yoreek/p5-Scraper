use 5.0100000;
use warnings;
use strict;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    NAME             => 'Scraper',
    VERSION_FROM     => 'lib/Scraper.pm',
    ABSTRACT_FROM    => 'lib/Scraper.pm',
    AUTHOR           => 'Yuriy Ustushenko <yoreek@yahoo.com>',
    EXE_FILES        => ['script/datacom.pl'],
    test             => {
        TESTS => 't/*.t'. ($ENV{AUTHOR_TESTING} ? ' xt/*.t' : '')
    },
    META_MERGE       => {
        'meta-spec' => { version => 2 },
        resources   => {
            license     => 'http://dev.perl.org/licenses/',
            homepage    => 'https://github.com/yoreek/p5-Scraper',
            repository => {
                type => 'git',
                url  => 'https://github.com/yoreek/p5-Scraper.git',
                web  => 'https://github.com/yoreek/p5-Scraper',
            },
            bugtracker => {
                web => 'https://github.com/yoreek/p5-Scraper/issues',
            },
        },
    },
    META_ADD         => {
        prereqs => {
            configure => {
                requires => {
                    'ExtUtils::MakeMaker'     => 0,
                },
            },
            runtime => {
                requires => {
                    'FindBin'                 => 0,
                    'Getopt::Long'            => 0,
                    'Pod::Usage'              => 0,
                    'Time::HiRes'             => 0,
                    'WWW::WebKit'             => 0,
                },
            },
            test => {
                requires => {
                    'Test::More'              => 0,
                },
            },
        },
    },
    MIN_PERL_VERSION => 5.010010,
    LICENSE          => 'perl_5',
);

my $eumm_version = eval $ExtUtils::MakeMaker::VERSION;

for (qw(configure build test runtime)) {
    my $key = $_ eq 'runtime' ? 'PREREQ_PM' : uc $_.'_REQUIRES';
    next unless exists $WriteMakefileArgs{META_ADD}{prereqs}{$_}
             or exists $WriteMakefileArgs{$key};
    my $r = $WriteMakefileArgs{$key} = {
        %{$WriteMakefileArgs{META_ADD}{prereqs}{$_}{requires} || {}},
        %{delete $WriteMakefileArgs{$key} || {}},
    };
    defined $r->{$_} or delete $r->{$_} for keys %$r;
}

$WriteMakefileArgs{BUILD_REQUIRES} = {
    %{$WriteMakefileArgs{BUILD_REQUIRES} || {}},
    %{delete $WriteMakefileArgs{TEST_REQUIRES}}
} if $eumm_version < 6.63_03;

$WriteMakefileArgs{PREREQ_PM} = {
    %{$WriteMakefileArgs{PREREQ_PM}},
    %{delete $WriteMakefileArgs{BUILD_REQUIRES}}
} if $eumm_version < 6.55_01;

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    if $eumm_version < 6.51_03;

delete @WriteMakefileArgs{qw(META_ADD META_MERGE)}
    if $eumm_version < 6.46;

delete $WriteMakefileArgs{MIN_PERL_VERSION}
    if $eumm_version < 6.48;

delete $WriteMakefileArgs{LICENSE}
    if $eumm_version < 6.31;

WriteMakefile(%WriteMakefileArgs);
