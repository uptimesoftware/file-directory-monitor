#!/usr/bin/perl -w

use File::stat;


# ($dir, $file, $recursive, $totalfiles, $nfname, $nfdatemodified, $nfdir, $lfname, $lfsizeinbytes, $lfdir)
sub search {
  local $dir            = $_[0];
  local $file           = $_[1];
  local $recursive      = $_[2];
  local $totalfiles     = $_[3];
  local $nfname         = $_[4];
  local $nfdatemodified = $_[5];
  local $nfdir          = $_[6];
  local $lfname         = $_[7];
  local $lfsizeinbytes  = $_[8];
  local $lfdir          = $_[9];

  local @files = <$dir/*>;
  foreach $curfile (@files) {
    # check sub-directories recursively
    if (-d "$curfile") {
      if (lc($recursive) =~ m/true/) {
        ($totalfiles, $nfname, $nfdatemodified, $nfdir, $lfname, $lfsizeinbytes, $lfdir) = search($curfile, $file, $recursive, $totalfiles, $nfname, $nfdatemodified, $nfdir, $lfname, $lfsizeinbytes, $lfdir);
      }
    }
    elsif (-f $curfile) {
      if ( ! defined($file) || $curfile =~ $file) {
        $totalfiles++;
        # check file modified date
        local $modtime = stat($curfile)->mtime;
        # check file modified date
        if ($modtime > $nfdatemodified) {
          $nfdatemodified = $modtime;
          $nfname         = $curfile;
          $nfdir          = $dir;
        }
        # check file size
        local $filesize = stat($curfile)->size;
        if ($filesize > $lfsizeinbytes) {
          $lfname         = $curfile;
          $lfsizeinbytes  = $filesize;
          $lfdir          = $dir;
        }
      }
    }
  }

  return ($totalfiles, $nfname, $nfdatemodified, $nfdir, $lfname, $lfsizeinbytes, $lfdir);
}




#on some OS/shell types you may need to change the below line to use $ARGV[0]
my $params = $ARGV[1];
my @values    = split('#', $params);
my $values_length = @values;

if ($values_length <= 1 )
{
  die "Unable to split first arg into params: @ARGV \n";
}

my $recursive = $values[0];
my $dir       = $values[1];
my $file      = $values[2];
my $timestamp = time();
if (defined($file)) {
  $file        =~ s/(\\s)/ /g;
}
my $totalfiles = 0;


# VARIABLES
# Newest File
my $nfname         = "";
my $nfdatemodified = 0;
my $nfdir          = "";
# Largest File
my $lfname         = "";
my $lfsizeinbytes  = 0;
my $lfdir          = "";


# MAIN
# check if the directory exists
if (-e $dir && -d $dir) {
  ($totalfiles, $nfname, $nfdatemodified, $nfdir, $lfname, $lfsizeinbytes, $lfdir) = search($dir, $file, $recursive, $totalfiles, $nfname, $nfdatemodified, $nfdir, $lfname, $lfsizeinbytes, $lfdir);
}
else {
  print "Message Error: Directory '$dir' does not exist!";
  exit(0);
}

# handle the condition if there are no files
if ($totalfiles == 0) {
  if (defined($file)) {
    print "Message No files were matched with '$file'.";
  }
  else {
    print "Message No files were found in '$dir'.";
  }
}
else {
  # do calculations
  # size to MB rounded to 2 decimal places
  my $lfsizeinkb = sprintf("%.3f", $lfsizeinbytes / 1024);
  my $lfsizeinmb = sprintf("%.3f", $lfsizeinbytes / 1024 / 1024);
  my $lfsizeingb = sprintf("%.3f", $lfsizeinbytes / 1024 / 1024 / 1024);
  my $lfsizeintb = sprintf("%.3f", $lfsizeinbytes / 1024 / 1024 / 1024 / 1024);
  # date to minutes
  my $minutesold = sprintf("%.1f", ($timestamp - $nfdatemodified) / 60);
  my $hoursold   = sprintf("%.1f", $minutesold / 60);
  my $daysold    = sprintf("%.1f", $minutesold / 60 / 24);

  my $str_oldest = "";
  if ($daysold > 1) {
    $str_oldest = "$daysold days old";
  }
  elsif ($hoursold > 1) {
    $str_oldest = "$hoursold hours old";
  }
  else {
    $str_oldest = "$minutesold minutes old";
  }

  # print the variables
  if ($lfsizeintb > 1.0) {
    print "Message Newest file: $nfdir$nfname ($str_oldest) -- Largest File: $lfdir$lfname ($lfsizeintb TB)\n";
  }
  elsif ($lfsizeingb > 1.0) {
    print "Message Newest file: $nfdir$nfname ($str_oldest) -- Largest File: $lfdir$lfname ($lfsizeingb GB)\n";
  }
  elsif ($lfsizeinmb > 1.0) {
    print "Message Newest file: $nfdir$nfname ($str_oldest) -- Largest File: $lfdir$lfname ($lfsizeinmb MB)\n";
  }
  elsif ($lfsizeinkb > 1.0) {
    print "Message Newest file: $nfdir$nfname ($str_oldest) -- Largest File: $lfdir$lfname ($lfsizeinkb KB)\n";
  }
  else {
    print "Message Newest file: $nfdir$nfname ($str_oldest) -- Largest File: $lfdir$lfname ($lfsizeinbytes Bytes)\n";
  }
  print "TotalSizeB $lfsizeinbytes\n";
  print "TotalSizeKB $lfsizeinkb\n";
  print "TotalSizeMB $lfsizeinmb\n";
  print "TotalSizeGB $lfsizeingb\n";
  print "TotalSizeTB $lfsizeintb\n";
  print "MinutesOld $minutesold\n";
  print "HoursOld $hoursold\n";
  print "DaysOld $daysold\n";
  print "TotalFiles $totalfiles\n";
}
