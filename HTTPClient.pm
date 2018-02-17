package HTTPClient;
use strict;
use warnings;

use HTTP::Tinyish;
use HTTP::Tiny 0.055;

sub _can_tls_12 {
    my $can_ssl = HTTP::Tiny->new(verify_SSL => 1)->can_ssl;
    $can_ssl && eval { require Net::SSLeay; Net::SSLeay->can("CTX_tlsv1_2_new") } ? 1 : 0;
}

sub _tinyish_backend {
    for my $try (map "HTTP::Tinyish::$_", qw(Curl Wget HTTPTiny LWP)) {
        if (my $meta = HTTP::Tinyish->configure_backend($try)) {
            if ($meta->supports("https")) {
                return $try;
            }
        }
    }
    die "No http clients are available";
}

my $CLASS;

sub create {
    my ($class, %args) = @_;
    $CLASS ||= _can_tls_12() ? "HTTP::Tiny" : _tinyish_backend();
    $CLASS->new(%args);
}

1;
