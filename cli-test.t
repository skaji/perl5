use 5.24.0;
use Test::More;

package Result {
    sub new {
        my $class = shift;
        bless {@_}, $class;
    }
    for my $attr (qw(out err exit status)) {
        no strict 'refs';
        *$attr = sub { shift->{$attr} };
    }
    sub success { shift->{status} == 0 }
}
package CLI {
    sub run {
        my ($class, @cmd) = @_;
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
        my $status = $?;
        seek $_, 0, 0 for $out_fh, $err_fh;
        my $out = join "", <$out_fh>;
        my $err = join "", <$err_fh>;
        Result->new(out => $out, err => $err, status => $status, exit => $status >> 8);
    }
}


my $r = CLI->run("df", "-h");

is $r->exit, 0;
like $r->out, qr/Filesystem/;
is $r->err, "";

done_testing;
