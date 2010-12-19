#!/usr/bin/perl

# cdbm - cd to directory by list of directory bookmarks
#
# reading of $HOME/.cdbm, all options and some major enhancements by
# Thomas Lange, lange@informatik,uni-koeln.de, 2001
# version 1.2, 02/2001
# Basic idea by Michael Schilli, iX 1/2001
#

use Getopt::Std;
use Cwd;

getopts('halr');
$opt_h && usage();

my @DIRS;
open (DIRS,"<$ENV{HOME}/.cdbm") || warn "Could not open $ENV{HOME}/.cdbm\n";
while (<DIRS>) {
  chomp;
  push @DIRS, $_;
}
close DIRS;

if (defined $ARGV[0]) {
  @MDIRS = grep /$ARGV[0]/io, @DIRS;
} else {
   @MDIRS = @DIRS;
}

$opt_l && list_dirs();
$opt_a && add_dir();
$opt_r && remove_entry();
change_dir();

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub change_dir {

  if(@MDIRS == 0) {
    warn "No match";
    print ".\n"; 

  } elsif (@MDIRS == 1) {
    print "$MDIRS[0]";

  } else {
    $input = mini_menu();
    if(exists $files{$input}) {
      print "$files{$input}";
    } else {
      warn "Invalid input";
      print ".\n";
    }
  }
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub remove_entry {

  if (@MDIRS == 0) {
    warn "No match\n";

  }elsif (@MDIRS == 1) {
    remove_e($MDIRS[0]);

  } else {
    $input = mini_menu();
    if (exists $files{$input}) {
      remove_e($files{$input});
    } else {
      warn "Invalid input";
    }
  }
  exit 0;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub remove_e {

  my $dir = shift;
# what about one grep and only one print join statement ?
  open (DIRS,">$ENV{HOME}/.cdbm");
  foreach (@DIRS) {
    $found = 1,next if /^$dir$/;
    print DIRS "$_\n";
  }
  close DIRS;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub mini_menu {

  my ($count,$input);

  foreach (@MDIRS) {
    $files{++$count} = $_;
    warn "[$count] $_\n";
  }

  print STDERR "[1-", scalar @MDIRS, "]> ";
  $input = <STDIN>;
  chomp($input);
  # default selection (just CR) is the first item
  ($input eq '') and $input = 1;
  return $input;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub list_dirs {

  foreach (@DIRS) {
    print "$_\n";
  }
  exit 0;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub add_dir {

# add current working directory to ~/.cdbm

  my $dir = cwd;
  # try to substitute home directory
  $dir =~ s#^$ENV{HOME}/#~/#;
  $dir =~ s#^$ENV{HOME}\b#~#;


  open (DIRS,">$ENV{HOME}/.cdbm") || die "Could not open $ENV{HOME}/.cdbm\n";
  foreach (@DIRS) {
    $found = 1 if /^$dir$/;
    print DIRS "$_\n";
  }

  unless ($found) {
     print DIRS "$dir\n";
     warn "$dir added to ~/.cdbm\n";
  }

  close DIRS;
  exit 0;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub usage {

  print <<'EOM';

NAME
         cdbm - select a directory by bookmark

SYNOPSIS
         cdbm [OPTION] [PATTERN]

DESCRIPTION

         Useful for changing into directories with a long path. Show a list
	 of directory bookmarks (from $HOME/.cdbm), which matches PATTERN. If
         multiple entries match, you can choose one using a simple menu. The
         command returns the selected directory. Using a shell alias, you can
	 easily change to a directory. You have to define an alias for your
         shell.

	   csh, tcsh:     alias c       'cd `cdbm \!:*`'
	    sh, bash:     function c() { cd `cdbm $1` }

OPTIONS

   -a            add current directory to $HOME/.cdbm if not already included.
                 A prefix, which is equal to $HOME will be replaced with ~

   -h            show this help

   -l            list contents of $HOME/.cdbm

   -r [PATTERN]  remove an entry from $HOME/.cdbm

EOM
  exit 0;
}
