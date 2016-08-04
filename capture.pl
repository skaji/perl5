#!/usr/bin/env perl
use 5.24.0;

=head1 DESCRIPTION

How to capture stdout and stderr for an external program

Of course, you can use Capture::Tiny if you have

=cut

sub capture {
    my @cmd = @_;
    open my $out_fh, "+>", undef;
    open my $err_fh, "+>", undef;

    my $pid = fork // die "fork: $!";
    if ($pid == 0) {
        open STDOUT, ">&", $out_fh;
        open STDERR, ">&", $err_fh;
        exec {$cmd[0]} @cmd;
        exit 255;
    }
    waitpid $pid, 0;
    my $exit = $?;
    seek $_, 0, 0 for $out_fh, $err_fh;
    my $out = join "", <$out_fh>;
    my $err = join "", <$err_fh>;
    return ($out, $err, $exit);
}


my ($out, $err, $exit) = capture $^X, "-E", 'say for 1..10; warn $_ for 1..5';
print "[$out]\n";
print "[$err]\n";
