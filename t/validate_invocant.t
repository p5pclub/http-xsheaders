#!perl -w

use strict;
use Test qw(plan ok skip);
use Scalar::Util qw(blessed);

BEGIN { plan tests => 37, todo => [] }

use HTTP::XSHeaders;

sub j { join("|", @_) }

my $h = new HTTP::XSHeaders;

ok(HTTP::XSHeaders::clone(undef), undef);
ok(HTTP::XSHeaders::clone("key0"), undef);
ok(blessed($h->clone()), 'HTTP::XSHeaders');

ok(HTTP::XSHeaders::clear(undef), undef);
ok(HTTP::XSHeaders::clear("key0"), undef);
ok($h->clear(), undef);

ok(HTTP::XSHeaders::init_header(undef), undef);
ok(HTTP::XSHeaders::init_header("key0"), undef);

ok(HTTP::XSHeaders::header_field_names(undef), undef);
ok(HTTP::XSHeaders::header_field_names("key0"), undef);

ok($h->init_header("kEy1", "value1"), undef);
ok($h->init_header("kEy2", "value2"), undef);
ok($h->header_field_names, 2);
ok(j($h->header_field_names), "Key1|Key2");

ok(HTTP::XSHeaders::push_header(undef), undef);
ok(HTTP::XSHeaders::push_header("key0"), undef);
ok($h->push_header("kEy1", "value3"), undef);

ok(HTTP::XSHeaders::header(undef), undef);
ok(HTTP::XSHeaders::header("key0"), undef);
ok($h->header("key0"), undef);
ok($h->header("key0", "value"), undef);
ok($h->header("key0"), "value");

ok(HTTP::XSHeaders::remove_header(undef), undef);
ok(HTTP::XSHeaders::remove_header("key0"), undef);
ok(j($h->remove_header("Key9")), "");
ok(j($h->remove_header("Key1")), "value1|value3");

ok(HTTP::XSHeaders::remove_content_headers(undef), undef);
ok(HTTP::XSHeaders::remove_content_headers("key0"), undef);
$h->header("Expires", "never");
$h->header("Last_Modified", "yesterday");
$h->header("Content-Test", "works");
ok(j($h->remove_content_headers()->as_string()), <<'EOS');
Expires: never
Last-Modified: yesterday
Content-Test: works
EOS

$h->header("AAA_header", "bilbo");

ok(HTTP::XSHeaders::as_string_without_sort(undef), undef);
ok(HTTP::XSHeaders::as_string_without_sort("key0"), undef);
ok(j($h->as_string_without_sort()), <<'EOS');
Key2: value2
Key0: value
Aaa-Header: bilbo
EOS

ok(HTTP::XSHeaders::as_string(undef), undef);
ok(HTTP::XSHeaders::as_string("key0"), undef);
ok(j($h->as_string()), <<'EOS');
Aaa-Header: bilbo
Key0: value
Key2: value2
EOS

# TODO: test invalid call to scan
#ok(HTTP::XSHeaders::scan(undef, undef), undef);
#ok(HTTP::XSHeaders::scan("key0", undef), undef);

ok(HTTP::XSHeaders::scan(undef, sub {}), undef);
ok(HTTP::XSHeaders::scan("key0", sub {}), undef);
