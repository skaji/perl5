#!/usr/bin/env perl
use 5.24.0;
use warnings;
use Parallel::Pipes;

=head1 DESCRIPTION

How to modify a subroutine at the runtime.

Hints:

  * You can use Scope::Guard to restore the original subroutine
  * But be careful about fork(2)

=cut

sub modify {
    my ($package, $sub_name, $code) = @_;
    no strict 'refs';
    no warnings 'redefine';
    my $orig = *{ $package . "::" . $sub_name }{CODE} || sub {};
    *{ $package . "::" . $sub_name } = sub { $code->($orig, @_) };
}

modify 'Parallel::Pipes', is_ready => sub {
    my ($orig, $self) = @_;
    my @ready = $self->$orig;
    $_->read for grep $_->is_written, @ready;
    @ready;
};

my $pipes = Parallel::Pipes->new(10, sub {
    my $task = shift;
    say "$$ done $task";
});

for my $task (1..100) {
    my ($ready) = $pipes->is_ready;
    $ready->write($task);
}
$pipes->close;
