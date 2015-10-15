use strict;
use warnings;

use Test::More;
plan tests => 7;

use HTTP::XSHeaders;

sub j { join('|', @_) }

my $h = new HTTP::XSHeaders;

$h->push_header('key1', 'value1-1');
$h->push_header('key2', 'value2-1');
$h->push_header('key2', 'value2-2');

is( j($h->_header('key0')), '', 'join inexistent key' );
is( j($h->_header('key1')), 'value1-1', 'join single-valued key' );
is( j($h->_header('key2')), 'value2-1|value2-2', 'join multi-valued key' );

$|++;
eval { require Test::Fatal; 1 } and do {
    like(
        Test::Fatal::exception(sub { HTTP::XSHeaders::_header() }),
        qr/\QUsage: HTTP::XSHeaders::_header(self, ...)\E/,
        'HTTP::XSHeaders::_header() without args',
        );
    is(
        HTTP::XSHeaders::_header(undef),
        undef,
        'HTTP::XSHeaders::_header() with undef'
        ) ;

    like(
        Test::Fatal::exception(sub { $h->_header() }),
        qr/\Q_header not called with one argument\E/,
        '_header() without args',
    );
    is(
        $h->_header(undef),
        undef,
        '_header() with undef'
        );
};

done_testing;
