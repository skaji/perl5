#!/usr/bin/env perl
use 5.14.0;

=head1 DESCRIPTION

How to do logging in your script without CPAN modules

They key is C<goto>.

=cut

package Logger {
    use POSIX ();
    use Carp ();
    sub _log {
        my ($die, $type) = (shift, shift);
        my $msg = @_ > 1 ? sprintf shift, @_ : shift;
        chomp $msg;
        $msg =~ s/\n/\\n/g;
        my $now = POSIX::strftime("%Y-%m-%d %H:%M:%S", localtime);
        $die ? Carp::croak("$now [$type] $msg") : Carp::carp("$now [$type] $msg");
    }
    sub debug { return unless $ENV{DEBUG}; _log(0, debug => @_) }
    sub info  { _log(0, info  => @_) }
    sub error { _log(0, error => @_) }
    sub croak { _log(1, error => @_) }
}

package App {
    sub debug { goto \&Logger::debug }
    sub info  { goto \&Logger::info  }
    sub error { goto \&Logger::error }
    sub croak { goto \&Logger::croak }

    sub example {
        info "you can use %s", "sprintf";
        debug "only \$ENV{DEBUG} is true";
        error "oops";
        croak "oops with die";
    }
}

App->example;
