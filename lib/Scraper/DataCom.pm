package Scraper::DataCom;
use warnings;
use strict;
use parent 'Scraper::Base';

use constant LOGIN_PAGE_URL              => "https://connect.data.com/login";
use constant SEARCH_LOAD_TIMEOUT         => 30;
use constant ELEMENT_SHOW_TIMEOUT        => 5;
use constant WAIT_PENDING_REQUESTS_SLEEP => 1;

sub new {
    my ($class, @args) = @_;

    my $self = $class->SUPER::new(
        username => undef,
        password => undef,
        _openned => 0,
        @args,
    );

    return $self;
}

sub findContacts {
    my ($self, $keywords, $opts) = @_;

    $opts              ||= {};
    $opts->{page_size} ||= 200;

    $self->login();
    $self->go_advanced_search();
    $self->fill_search_form($keywords, $opts);
    $self->submit_search_form();
    my $results = $self->parse_search_results($opts->{page_size});

    return $results;
}

sub login {
    my ($self) = @_;

    unless ($self->{_openned}) {
        $self->drv->open(LOGIN_PAGE_URL);
        $self->{_openned} = 1;
    }

    return if $self->is_logged();

    $self->logger->debug('Try to login');

    $self->drv->type("id=j_username", $self->{username});
    $self->drv->type("id=j_password", $self->{password});
    $self->drv->click("id=login_btn");

    die "Request timeout"
        unless $self->drv->wait_for_page_to_load();

    die "Failed to login"
        unless $self->is_logged();
}

sub is_logged {
    my ($self) = @_;
    return $self->drv->is_element_present('id=headerCartCount');
}

sub go_advanced_search {
    my ($self) = @_;

    $self->logger->debug("Load advanced search page");

    $self->drv->click("id=homepageAdvancedSearch");

    die "Request timeout"
        unless $self->drv->wait_for_page_to_load();

    die "Failed to load asvanced search page"
        unless $self->drv->is_element_present("id=findContacts");
}

sub fill_search_form {
    my ($self, $keywords, $opts) = @_;

    $opts ||= {};

    $self->logger->debug('Fill search form');

    $self->drv->type_keys(".//div[\@id='findContacts']//input[\@name='titles']", $keywords);

    if ($opts->{country}) {
        $self->drv->check(".//div[\@id='findContacts']//div[\@id='locationType']//label[contains(text(), '$opts->{country}')]");
    }
}

sub submit_search_form {
    my ($self) = @_;

    $self->logger->debug('Submit');

    my $searchButton = $self->drv->wait_for_condition(sub {
        my $button = $self->drv->is_element_present("(.//div[\@id='findContacts']//button[contains(\@class, 'search-button')])[2]")
            or return;
        my $enabled = ($button->has_attribute('disabled') ? 0 : 1)
            or return;
        return $button;
    }, ELEMENT_SHOW_TIMEOUT * 1000);

    die "No search button"
        unless $searchButton;

    $self->drv->click("(.//div[\@id='findContacts']//button[contains(\@class, 'search-button')]/span)[1]");
    $self->drv->wait_for_pending_requests(SEARCH_LOAD_TIMEOUT * 1000, WAIT_PENDING_REQUESTS_SLEEP * 1000);
}

sub parse_search_results {
    my ($self, $page_size) = @_;

    $page_size ||= 200;

    $self->logger->debug('Parse results');

    my $resultCountElement = $self->drv->wait_for_condition(sub {
        $self->drv->is_element_present("(.//div[\@id='findContacts']//span[contains(\@class, 'resultCount')])[1]");
    }, ELEMENT_SHOW_TIMEOUT * 1000);

    die "No results"
        unless $resultCountElement;

    my $resultCount = $resultCountElement->get_text_content();
    $resultCount =~ s/,//g;
    $self->logger->debug('resultCount: ' . $resultCount);
    return unless $resultCount;

    my $pageSize = $self->drv->get_value("(.//div[\@id='findContacts']//select[\@id='pageSize'])[1]");
    $self->logger->debug('pageSize: ' . $pageSize);

    $self->drv->select("(.//div[\@id='findContacts']//select[\@id='pageSize'])[1]",
                       "option[\@value='$page_size']");
    $self->drv->wait_for_pending_requests(SEARCH_LOAD_TIMEOUT * 1000, WAIT_PENDING_REQUESTS_SLEEP * 1000);

    my $results = $self->drv->resolve_locator("(.//div[\@id='findContacts']//table[contains(\@class, 'result')])[1]");

    $self->logger->debug("results: " . $results->get_inner_html())
        if $self->logger->is_debug();

    return $results->get_inner_html();
}

1;
