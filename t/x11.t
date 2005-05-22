#!perl -w
use Test;

my $glxinfo = '/usr/X11R6/bin/glxinfo';
unless (-x $glxinfo) {
  print "1..0 # skip: needs glxinfo\n";
  exit;
}

plan tests => 13;

use strict;
use ActiveState::X11TestServer;

ok 1;

#Remote test
{
my $x11; 
eval { 
  $x11 = ActiveState::X11TestServer->new(
    order => [qw(remote)],
  );
};
ok !$@;
ok $x11;
ok $x11 && $x11->display;
ok glx_ok($x11);
}

#Local test
{
my $x11;
eval { 
  $x11 = ActiveState::X11TestServer->new(
    order => [qw(local)],
  );
};
ok !$@;
ok $x11;
ok $x11 && $x11->display;
ok glx_ok($x11); 
}

#Managed test
{
my $x11;
eval { 
  $x11 = ActiveState::X11TestServer->new(
    order => [qw(managed)],
  );
};
ok !$@;
ok $x11;
ok $x11 && $x11->display;
ok glx_ok($x11); 
}              

sub glx_ok {
 my $x = shift;
 return unless $x;
 my $display = $x->display;
 return unless $display;
 local $ENV{DISPLAY} = $display;
 print STDERR "# Display = '$display'\n";
 open(my $info, "$glxinfo -b |") || die "glxinfo failure: $!";
 my $pass = 0;
 while(<$info>) {
   $pass ++ if /^\d+$/;
 }
 close($info);
 return $pass;
}
