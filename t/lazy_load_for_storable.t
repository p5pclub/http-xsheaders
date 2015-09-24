use strict;
use warnings;
use HTTP::XSHeaders;
use Test::More tests => 1;

is $INC{'Storable.pm'}, undef;
