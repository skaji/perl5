#!/usr/bin/env perl
use 5.24.0;

sub fillin {
    my ($template, $hash) = @_;
    $template =~ s/\{\{ \s* (\S+?) \s* \}\}/ $hash->{$1} or die "undefined var '$1'\n" /xge;
    $template;
}

print fillin <<'___', { name => 'Shoichi Kaji', email => 'skaji@cpan.org' };
This software is copyright (c) 2016 by {{name}} <{{email}}>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
___
