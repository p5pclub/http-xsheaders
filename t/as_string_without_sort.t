use strict;
use Test::More tests => 2;
BEGIN { use_ok('HTTP::XSHeaders') }

my $h = HTTP::XSHeaders->new(foo => "bar", foo => "baaaaz", Foo => "baz");
ok($h->as_string_without_sort(), "Foo: bar\nFoo: baaaaz\nFoo: baz\n");

