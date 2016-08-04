#!/usr/bin/env perl
use 5.24.0;

=head1 DESCRIPTION

Do not use Sys::SigAction::timeout_call

=cut

sub timeout_call {
    my ($sec, $cb) = @_;

    local $SIG{__DIE__} = 'DEFAULT';
    local $SIG{ALRM} = 'DEFAULT';

    my $error;
    # this block is needed for perl < 5.14.0
    # https://metacpan.org/pod/distribution/perl/pod/perl5140delta.pod#Exception-Handling
    {
        local $@;
        eval {
            local $SIG{ALRM} = sub { die "__TIMEOUT__\n" };
            alarm $sec;
            $cb->();
            alarm 0;
        };
        $error = $@;
        alarm 0;
    }

    if ($error) {
        if ($error eq "__TIMEOUT__\n") {
            return 1;
        } else {
            die $error;
        }
    } else {
        return;
    }
}

use HTTP::Tiny;
use Data::Dump;

my $res;
my $is_timeout = timeout_call 5, sub {
    $res = HTTP::Tiny->new->get("http://www.yahoo.co.jp");
};

if ($is_timeout) {
    die "timeout";
} else {
    dd $res;
}
