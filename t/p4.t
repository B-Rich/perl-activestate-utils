#!/usr/bin/perl -w

use strict;
use Test;
BEGIN { plan tests => 8 }

use ActiveState::P4 qw(:all);
ok(1);

my @changes = p4_changes('//depot/main/support/modules/ActiveState-Utils/...');
ok(grep { $_ eq '34459' } @changes);

my %desc = p4_describe(34459);
ok($desc{date_p4}, '2002/01/18 16:04:04');
ok($desc{user},    'neilw@neilw-alfalfa');
ok(scalar keys %{$desc{files}}, 4);

ok(p4_exists("//depot/main/Apps/..."), 1);
ok(p4_exists("//depot/fuzzy/bear/..."), 0);

ok(p4_info()->{server_license} =~ /ActiveState/);
