#!/usr/bin/perl -w

binmode(STDOUT, ":utf8");

use strict;
use warnings;
use utf8;
use Data::Dumper;
use JSON;
use HTML::TreeBuilder::XPath;
use WWW::Mechanize;
use Log::Log4perl;
use Encode;
use constant FEED_MIME_TYPES => [
    'application/x.atom+xml',
    'application/atom+xml',
    'application/xml',
    'text/xml',
    'application/rss+xml',
    'application/rdf+xml',
];

Log::Log4perl::init('/docker/log4perl.conf');

my $logger = Log::Log4perl->get_logger('rss');
my %IsFeed = map { $_ => 1 } @{ FEED_MIME_TYPES() };
my %output_json = (
  rss  => [],
  atom => []
);

$logger->info("rss_link_collector started!");

my $page_tree = HTML::TreeBuilder->new();
while (my $row = <STDIN>) {
  $page_tree->parse($row);
}
$page_tree->eof();

$logger->info("Input was received.");
$logger->info("Collect the links from the input.");
my @feed_links;
foreach my $a_href ($page_tree -> findvalues(qq{//a/\@href})) {
  if ($a_href =~ m/^http(s?):\/\/.*/) {
    push(@feed_links, $a_href);
  }
}

foreach my $link_href ($page_tree -> findvalues(qq{//link/\@href})) {
  if ($link_href =~ m/^http(s?):\/\/.*/) {
    push(@feed_links, $link_href);
  }
}

foreach my $link (@feed_links) {
  my $mech = WWW::Mechanize->new(autocheck => 0, ssl_opts => {SSL_verify_mode => "IO::Socket::SSL::SSL_VERIFY_NONE", verify_hostname => 0});
  my $feed_page = $mech->get($link);

  if ($mech->success()) {
    if($IsFeed{$feed_page->content_type}) {
      my $content = $feed_page->decoded_content();
      if (index($content, "rss") > -1) {
        push(@{$output_json{rss}}, $link);
      } elsif (index($content, "feed") > -1) {
        push(@{$output_json{atom}}, $link);
      }
    }
  } else {
    $logger->error("The URL [" . $link . "] retrieves the following error: " . $mech->status());
  }
}

print encode_json \%output_json;
print "\n";

$logger->info("rss_link_collector finished!");
exit 0;
