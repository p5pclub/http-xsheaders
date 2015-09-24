package HTTP::XSHeaders;
use strict;
use warnings;
use XSLoader;

our $VERSION = '0.11';

require HTTP::Headers::Fast;
XSLoader::load( 'HTTP::XSHeaders', $VERSION );

# Implemented in XS
*HTTP::Headers::Fast::new =
    *HTTP::XSHeaders::new;
*HTTP::Headers::Fast::DESTROY =
    *HTTP::XSHeaders::DESTROY;
*HTTP::Headers::Fast::clone =
    *HTTP::XSHeaders::clone;
*HTTP::Headers::Fast::header =
    *HTTP::XSHeaders::header;
*HTTP::Headers::Fast::clear =
    *HTTP::XSHeaders::clear;
*HTTP::Headers::Fast::push_header =
    *HTTP::XSHeaders::push_header;
*HTTP::Headers::Fast::init_header =
    *HTTP::XSHeaders::init_header;
*HTTP::Headers::Fast::remove_header =
    *HTTP::XSHeaders::remove_header;
*HTTP::Headers::Fast::remove_content_headers =
    *HTTP::XSHeaders::remove_content_headers;
*HTTP::Headers::Fast::as_string =
    *HTTP::XSHeaders::as_string;
*HTTP::Headers::Fast::as_string_without_sort =
    *HTTP::XSHeaders::as_string_without_sort;
*HTTP::Headers::Fast::header_field_names =
    *HTTP::XSHeaders::header_field_names;
*HTTP::Headers::Fast::scan =
    *HTTP::XSHeaders::scan;

# Implemented in Pure-Perl
# (candidates to move to XS)
*HTTP::Headers::Fast::_date_header =
    *HTTP::XSHeaders::_date_header;
*HTTP::Headers::Fast::content_type =
    *HTTP::XSHeaders::content_type;
*HTTP::Headers::Fast::content_type_charset =
    *HTTP::XSHeaders::content_type_charset;
*HTTP::Headers::Fast::referer =
    *HTTP::XSHeaders::referer;
*HTTP::Headers::Fast::referrer =
    *HTTP::XSHeaders::referer;

*HTTP::Headers::Fast::_basic_auth =
    *HTTP::XSHeaders::_basic_auth;

{
    no warnings qw<redefine once>;
    for my $key (qw/content-length content-language content-encoding title user-agent server from warnings www-authenticate authorization proxy-authenticate proxy-authorization/) {
      (my $meth = $key) =~ s/-/_/g;
      no strict 'refs';
      *{ "HTTP::Headers::Fast::$meth" } = sub {
          # print STDERR "*** GONZO: method [$meth]\n";
          (shift->header($key, @_))[0];
      };
    }
}

use 5.00800;
use Carp ();

sub _date_header {
    require HTTP::Date;
    my ( $self, $header, $time ) = @_;
    my $old;
    if ( defined $time ) {
        ($old) = $self->header($header, HTTP::Date::time2str($time));
    } else {
        ($old) = $self->header($header);
    }
    $old =~ s/;.*// if defined($old);
    HTTP::Date::str2time($old);
}

sub content_type {
    my $self = shift;
    my $ct   = $self->header('content-type');
    $self->header('content-type', shift) if @_;
    $ct = $ct->[0] if ref($ct) eq 'ARRAY';
    return '' unless defined($ct) && length($ct);
    my @ct = split( /;\s*/, $ct, 2 );
    for ( $ct[0] ) {
        s/\s+//g;
        $_ = lc($_);
    }
    wantarray ? @ct : $ct[0];
}

# This is copied here because it is not a method
sub _split_header_words
{
    my(@val) = @_;
    my @res;
    for (@val) {
	my @cur;
	while (length) {
	    if (s/^\s*(=*[^\s=;,]+)//) {  # 'token' or parameter 'attribute'
		push(@cur, $1);
		# a quoted value
		if (s/^\s*=\s*\"([^\"\\]*(?:\\.[^\"\\]*)*)\"//) {
		    my $val = $1;
		    $val =~ s/\\(.)/$1/g;
		    push(@cur, $val);
		# some unquoted value
		}
		elsif (s/^\s*=\s*([^;,\s]*)//) {
		    my $val = $1;
		    $val =~ s/\s+$//;
		    push(@cur, $val);
		# no value, a lone token
		}
		else {
		    push(@cur, undef);
		}
	    }
	    elsif (s/^\s*,//) {
		push(@res, [@cur]) if @cur;
		@cur = ();
	    }
	    elsif (s/^\s*;// || s/^\s+//) {
		# continue
	    }
	    else {
		die "This should not happen: '$_'";
	    }
	}
	push(@res, \@cur) if @cur;
    }

    for my $arr (@res) {
	for (my $i = @$arr - 2; $i >= 0; $i -= 2) {
	    $arr->[$i] = lc($arr->[$i]);
	}
    }
    return @res;
}

sub content_type_charset {
    my $self = shift;
    my $h = $self->header('content-type');
    $h = $h->[0] if ref($h);
    $h = "" unless defined $h;
    my @v = _split_header_words($h);
    if (@v) {
        my($ct, undef, %ct_param) = @{$v[0]};
        my $charset = $ct_param{charset};
        if ($ct) {
            $ct = lc($ct);
            $ct =~ s/\s+//;
        }
        if ($charset) {
            $charset = uc($charset);
            $charset =~ s/^\s+//;  $charset =~ s/\s+\z//;
            undef($charset) if $charset eq "";
        }
        return $ct, $charset if wantarray;
        return $charset;
    }
    return undef, undef if wantarray;
    return undef;
}

sub referer {
    my $self = shift;
    if ( @_ && $_[0] =~ /#/ ) {

        # Strip fragment per RFC 2616, section 14.36.
        my $uri = shift;
        if ( ref($uri) ) {
            require URI;
            $uri = $uri->clone;
            $uri->fragment(undef);
        }
        else {
            $uri =~ s/\#.*//;
        }
        unshift @_, $uri;
    }
    ( $self->header( 'Referer', @_ ) )[0];
}

sub _basic_auth {
    require MIME::Base64;
    my ( $self, $h, $user, $passwd ) = @_;
    my ($old) = $self->header($h);
    if ( defined $user ) {
        Carp::croak("Basic authorization user name can't contain ':'")
          if $user =~ /:/;
        $passwd = '' unless defined $passwd;
        $self->header(
            $h => 'Basic ' . MIME::Base64::encode( "$user:$passwd", '' ) );
    }
    if ( defined $old && $old =~ s/^\s*Basic\s+// ) {
        my $val = MIME::Base64::decode($old);
        return $val unless wantarray;
        return split( /:/, $val, 2 );
    }
    return;
}

1;

__END__

=pod

=head1 NAME

HTTP::XSHeaders - HTTP::Headers::Fast with XS and a C data structure

=head1 SYNOPSIS

    # load once
    use HTTP::XSHeaders;

    # keep using HTTP::Headers::Fast as you wish

=head1 DESCRIPTION

By loading L<HTTP::XSHeaders> anywhere, you replace any usage
of L<HTTP::Headers::Fast> with the XS implementation.

You can continue to use L<HTTP::Headers::Fast> and any other module that
depends on it just like you did before. It's just faster now.

=head1 METHODS
