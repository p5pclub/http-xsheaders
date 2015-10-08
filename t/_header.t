#!perl -w

use strict;
use Test qw(plan ok skip);

BEGIN { plan tests => 3, todo => [] }

use HTTP::XSHeaders;

sub j { join("|", @_) }

my $h = new HTTP::XSHeaders;

$h->push_header("key1", "value1-1");
$h->push_header("key2", "value2-1");
$h->push_header("key2", "value2-2");

# ToDo: test call with no args or with more than 1 arg
#ok(j($h->_header()), "");
#ok(j($h->_header('a', 'b', 'c')), "");

ok(j($h->_header("key0")), "");
ok(j($h->_header("key1")), "value1-1");
ok(j($h->_header("key2")), "value2-1|value2-2");
