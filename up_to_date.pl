#!/usr/bin/env perl
use strict;
use warnings;

# from Module::Build::Base
sub up_to_date {
    my ($source, $derived) = @_;
    $source  = [$source]  unless ref $source;
    $derived = [$derived] unless ref $derived;

    # empty $derived means $source should always run
    return 0 if @$source && !@$derived || grep {not -e} @$derived;

    my $most_recent_source = time / (24*60*60);
    for my $file (@$source) {
        if (!-e $file) {
            warn "Can't find source file $file for up-to-date check";
            next;
        }
        $most_recent_source = -M _ if -M _ < $most_recent_source;
    }

    for my $derived (@$derived) {
        return 0 if -M $derived > $most_recent_source;
    }
    return 1;
}
