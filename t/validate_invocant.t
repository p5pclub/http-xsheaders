use strict;
use warnings;

use Test::More;
plan tests => 46;

use HTTP::XSHeaders;

my $h = HTTP::XSHeaders->new;

is( HTTP::XSHeaders::clone(undef), undef, 'clone(undef)' );
is( HTTP::XSHeaders::clone("key0"), undef, 'clone with arg' );
isa_ok( $h->clone, 'HTTP::XSHeaders' );

is( HTTP::XSHeaders::clear(undef), undef, 'clear(undef)' );
is( HTTP::XSHeaders::clear("key0"), undef, 'clear with arg' );
is( $h->clear(), undef, 'clear()' );

is( HTTP::XSHeaders::init_header("key0"), undef, 'init_header with arg' );

is( HTTP::XSHeaders::header_field_names(undef), undef, 'header_field_names(undef)' );
is( HTTP::XSHeaders::header_field_names("key0"), undef, 'header_field_names with arg' );

is( $h->init_header("kEy1", "value1"), undef, 'initialize first key' );
is( $h->init_header("kEy2", "value2"), undef, 'initialize second key' );
is( $h->header_field_names, 2, 'got two headers' );
is_deeply( [$h->header_field_names], ['Key1', 'Key2'], 'header_field_names' );

is( HTTP::XSHeaders::push_header(undef), undef, 'push_header(undef)' );
is( HTTP::XSHeaders::push_header("key0"), undef, 'push_header with arg' );
is( $h->push_header("kEy1", "value3"), undef, 'push_header method with two args' );

is( HTTP::XSHeaders::header(undef), undef, 'header(undef)' );
is( HTTP::XSHeaders::header("key0"), undef, 'header with arg' );
is( $h->header("key0"), undef, 'header method with arg' );
is( $h->header("key0", "value"), undef, 'header method with two args' );
is( $h->header("key0"), "value", 'getting header value for key' );

is( HTTP::XSHeaders::remove_header(undef), undef, 'remove_header(undef)' );
is( HTTP::XSHeaders::remove_header("key0"), undef, 'remove_header with arg' );
is_deeply( [$h->remove_header("Key9")], [], 'remove_header method with key and single value' );
is_deeply( [$h->remove_header("Key1")], [qw<value1 value3>], 'remove header with multiple values' );

is( HTTP::XSHeaders::remove_content_headers(undef), undef, 'remove_content_header(undef)' );
is( HTTP::XSHeaders::remove_content_headers("key0"), undef, 'remove_content_header with arg' );

$h->header("Expires", "never");
$h->header("Last_Modified", "yesterday");
$h->header("Content-Test", "works");

is( $h->remove_content_headers()->as_string(), <<'EOS', 'remove_content_headers->as_string' );
Expires: never
Last-Modified: yesterday
Content-Test: works
EOS

$h->header("AAA_header", "bilbo");

is( HTTP::XSHeaders::as_string_without_sort(undef), undef, 'as_string_without_sort(undef)' );
is( HTTP::XSHeaders::as_string_without_sort("key0"), undef, 'as_string_without_sort with arg' );
is( $h->as_string_without_sort(), <<'EOS', 'as_string_without_sort method' );
Key2: value2
Key0: value
Aaa-Header: bilbo
EOS

is( HTTP::XSHeaders::as_string(undef), undef, 'as_string(undef)' );
is( HTTP::XSHeaders::as_string("key0"), undef, 'as_string with arg' );
is( $h->as_string(), <<'EOS', 'as_string method' );
Aaa-Header: bilbo
Key0: value
Key2: value2
EOS

$|++;
eval { require Test::Fatal; 1 } and do {
    # test invalid call to scan
    is(
        HTTP::XSHeaders::scan(undef, undef),
        undef,
        'scan() without coderef',
    );

    is(
        HTTP::XSHeaders::scan('key0', undef),
        undef,
        'scan() with string as self',
    );

    like(
        Test::Fatal::exception(sub { $h->scan() }),
        qr/\QUsage: HTTP::XSHeaders::scan(self, sub)\E/,
        'scan() without arguments',
    );

    like(
        Test::Fatal::exception(sub { $h->scan(undef) }),
        qr/\QSecond argument must be a CODE reference\E/,
        'scan() without coderef',
    );

    is(
        $h->scan(sub {1} ),
        undef,
        'scan() with coderef',
    );

    like(
        Test::Fatal::exception(sub { HTTP::XSHeaders::init_header() }),
        qr/\QUsage: HTTP::XSHeaders::init_header(self, ...)\E/,
        'HTTP::XSHeaders::init_header()'
        );
    is(
        Test::Fatal::exception(sub { HTTP::XSHeaders::init_header(undef) }),
        undef,
        'HTTP::XSHeaders::init_header(undef)'
        );
    is(
        Test::Fatal::exception(sub { HTTP::XSHeaders::init_header(undef, undef) }),
        undef,
        'HTTP::XSHeaders::init_header(undef, undef)'
        );
    is(
        Test::Fatal::exception(sub { HTTP::XSHeaders::init_header(undef, undef, undef) }),
        undef,
        'HTTP::XSHeaders::init_header(undef, undef, undef)'
        );
    like(
        Test::Fatal::exception(sub { $h->init_header() }),
        qr/\Qinit_header needs two arguments\E/,
        'init_header()'
        );
    like(
        Test::Fatal::exception(sub { $h->init_header(undef) }),
        qr/\Qinit_header needs two arguments\E/,
        'init_header(undef)'
        );
    like(
        Test::Fatal::exception(sub { $h->init_header(undef, undef) }),
        qr/\Qinit_header not called with a first string argument\E/,
        'init_header(undef, undef)'
        );

};

done_testing;
