#!/usr/bin/perl -w

binmode(STDOUT, ":utf8");

use strict;
use warnings;
use utf8;
use Data::Dumper;
use JSON;
use HTML::TreeBuilder::XPath;
use WWW::Mechanize;
use Encode;
use constant FEED_MIME_TYPES => [
    'application/x.atom+xml',
    'application/atom+xml',
    'application/xml',
    'text/xml',
    'application/rss+xml',
    'application/rdf+xml',
];

sub get_links {
  my $content = shift;

  my @tags;

  my $page_tree = HTML::TreeBuilder::XPath -> new_from_content(decode_utf8 $content);
  foreach my $a_href ($page_tree -> findvalues(qq{//a/\@href})) {
    if ($a_href =~ m/^http(s?):\/\/.*/) {
      push(@tags, $a_href);
    }
  }

  foreach my $link_href ($page_tree -> findvalues(qq{//link/\@href})) {
    if ($link_href =~ m/^http(s?):\/\/.*/) {
      push(@tags, $link_href);
    }
  }

  return \@tags;
}

my %IsFeed = map { $_ => 1 } @{ FEED_MIME_TYPES() };

my %output_json = (
  rss  => [],
  atom => []
);

my $inputfile;
{
  local $/;
  while(<>) {
    $inputfile = $_;
  }
}

my @feed_links = @{get_links($inputfile)};

foreach my $link (@feed_links) {
  my $mech = WWW::Mechanize->new(ssl_opts => {SSL_verify_mode => "IO::Socket::SSL::SSL_VERIFY_NONE", verify_hostname => 0});
  my $feed_page = $mech->get($link);

  if($IsFeed{$feed_page->content_type}) {
    my $content = $feed_page->decoded_content();
    if (index($content, "rss") > -1) {
      push(@{$output_json{rss}}, $link);
    } elsif (index($content, "feed") > -1) {
      push(@{$output_json{atom}}, $link);
    }
  }
}

print "\n";
print encode_json \%output_json;
print "\n";

exit 0;
