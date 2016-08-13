#!/usr/bin/env perl
use 5.24.0;
use File::Temp ();
use File::Copy ();
use File::Basename ();
use Fcntl ();

sub x_tempfile {
    my $file = shift;
    # from HTTP::Tiny::mirror()
    my $tempfile = "$file.$$." . int(rand(2**31));
    my $flag = Fcntl::O_EXCL() | Fcntl::O_CREAT() | Fcntl::O_WRONLY();
    sysopen my $fh, $tempfile, $flag or return;
    ($fh, $tempfile);
}

sub atomic_copy_p {
    my ($from, $target) = @_;
    my $dir  = File::Basename::dirname($target);
    my $base = File::Basename::basename($target);
    my ($temp_fh, $temp_name) = File::Temp::tempfile(
        DIR => $dir,
        TEMPLATE => "$base.XXXXX",
        UNLINK => 0,
        EXLOCK => 0,
    );
    File::Copy::copy($from, $temp_fh) or return;
    close $temp_fh;
    my ($mode, $atime, $mtime) = (stat $from)[2, 8, 9];
    utime $atime, $mtime, $temp_name;
    chmod $mode, $temp_name;
    rename $temp_name, $target;
}

sub atomic_copy_2 {
    my ($from, $target) = @_;
    my ($tempfh, $tempfile) = x_tempfile $target;
    $tempfh or return;
    File::Copy::copy($from, $tempfh) or return;
    close $tempfh;
    rename $tempfile, $target;
}

atomic_copy_2 $0, "file.log";
