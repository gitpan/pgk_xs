use ExtUtils::MakeMaker;
use Config;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

print "\nStarting pgk configuration...\n\n";

#########################################################################################

my $GTKLIB;
my $GTKINC;
my $GLIBLIB;
my $GLIBINC;
my $ELIBS;
my $ECFLAGS;
my $PREPREFIX;

my $UNIX=not isWin32();

if ($UNIX) {
  print "isWin32() returns 0, we assume that we're on UNIX\n";
  print "\n";
  
  if (not $ENV{'DISPLAY'}) {
     die "You need a DISPLAY variable set in order to test this package!\n";
  }

  open IN, "gtk-config --cflags |" or die "put gtk-config in your path";
  print "reading GTKINC from gtk-config --cflags\n";
  $GTKINC=trim(<IN>);
  close IN;

  open IN, "gtk-config --libs |" or die "put gtk-config in your path";
  print "reading GTKLIB from gtk-config --libs\n";
  $GTKLIB=trim(<IN>);
  close IN;

  open IN, "glib-config --cflags |" or die "put glib-config in your path";
  print "reading GLIBINC from glib-config --cflags\n";
  $GLIBINC=trim(<IN>);
  close IN;

  open IN, "glib-config --libs |" or die "put glib-config in your path";
  print "reading GLIBLIB from glib-config --libs\n";
  $GLIBLIB=trim(<IN>);
  close IN;
}
else {
  my $GLIB="glib-2.0";
  my $GTK="gtk-1.3";
  my $DEVEL="C:\\mingw";

  print "isWin32() returns 1, we assume that we're on a Win32 system\n";
  print "\n";

  $GTKLIB=("-L$DEVEL/lib -lgtk -lgdk");
  $GTKINC="-I$DEVEL/include/$GTK -I$DEVEL/lib/gtk+/include";
  $GLIBLIB=("-L$DEVEL/lib/$GLIB -lglib -lgmodule");
  $GLIBINC="-I$DEVEL/include/$GLIB -I$DEVEL/lib/$GLIB/include";
  $ELIBS="";
  $ECFLAGS="-mno-cygwin  -mms-bitfields";
  $PREPREFIX="C:\\projects\\perlmods";
}

#########################################################################################

print "GTKINC=$GTKINC\n";
print "GTKLIB=$GTKLIB\n";
print "GLIBINC=$GLIBINC\n";
print "GLIBLIB=$GLIBLIB\n";
print "ECFLAGS=$ECFLAGS\n";
print "ELIBS=$ELIBS\n";
print "\n";
  
#########################################################################################

WriteMakefile(
    'NAME'          => 'pgk_xs',
    'VERSION_FROM'  => 'pgk.pm',
    'LIBS'          => ["$GTKLIB $GLIB $ELIBS"],   # e.g., '-lm' 
#    'LDLOADLIBS'    => "$GTKLIB $GLIBLIB $ELIBS",
    'INC'           => "$ECFLAGS $GTKINC $GLIBINC",     # e.g., '-I/usr/include/other' 
    'INSTALLDIRS'   => 'perl', # 'perl' makes it replace std modules
#   'PREFIX'        => "$PREPREFIX",
);

#########################################################################################

sub isWin32 {
  my $win32=0;
  open IN,"perl --version |";
  while(<IN>) {
    if (/win32/i) { $win32=1;last; }
  }
  close IN;
return $win32;
}

sub trim {
  my $s=shift;
  $s=~s/^\s+//;
  $s=~s/\s+$//;
return $s;
}
