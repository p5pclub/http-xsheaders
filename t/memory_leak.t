#!perl
use strict;
use warnings;
use Test::More;
use HTTP::XSHeaders;

eval { require Test::MemoryGrowth; 1; }
  or plan skip_all => 'Test::MemoryGrowth is needed for this test';

Test::MemoryGrowth::no_growth(sub {
  my $hdrs = HTTP::Headers::Fast->new();
  $hdrs->push_header( foo => 'bar' );
});

done_testing;
