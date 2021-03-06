#!perl -w

BEGIN {
    if ($^O eq "MSWin32") {
	print "1..0 # Skipped: ActiveState::DiskUsage does not work on Windows\n";
	exit 0;
    }
}

print "1..1\n";

use strict;
use ActiveState::DiskUsage qw(du);

my $du1 = du(".");

`du -s -k .` =~ /^(\d+)/ || die;
my $du2 = $1 * 1024;

print "# $du1 $du2\n";
print "not " unless abs($du1 - $du2) <= 512;
print "ok 1\n";
