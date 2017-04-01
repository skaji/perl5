#!/usr/bin/env perl
use 5.24.0;
use warnings;
use experimental 'signatures';


require "perl5db.pl"; $DB::single = 1; DB::DB();
# y -> lexical変数一覧
