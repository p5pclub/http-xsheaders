package FakeHash {
    use strict;
    use warnings;
    use Tie::Hash;
    use parent -norequire, 'Tie::ExtraHash';
}

use strict;
use warnings;
use Test::More;

my $class_base = 'HTTP::Headers';
my $class_xs = 'HTTP::XSHeaders';
use_ok($class_base);
use_ok($class_xs);

tie my %newhash, 'FakeHash';
my $headers = bless \%newhash => $class_base;

is( ref $headers, $class_base, "Correct reference for hashref: $class_base" );
ok( tied(%newhash), "Correct tie for hash" );
is( tied($headers), undef, "Correct tie for hashref: undef" );

my %data = (
    'X-Foo' => 'Bar',
);
foreach my $key (keys %data) {
    my $val = $data{$key};
    $headers->push_header( $key, $val );
}
foreach my $key (keys %data) {
    my $val = $data{$key};
    is( $headers->header($key), $val, "Header $key was set correctly to $val" );
}

done_testing();
