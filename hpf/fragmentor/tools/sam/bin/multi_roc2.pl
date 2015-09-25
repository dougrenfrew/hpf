#!/usr/local/bin/perl

# multi_roc2.pl
# written by Rachel Karchin Aug. 1996 for UCSC Computational Biology
#
# this script takes a series of triples - each triple contains a pair
# of distance files and a title.
# The pair of distance files must be a "true file" and a "false file".
# The "true file" contains the scores of members of a particular protein
# family; the "false file" contains scores of nonmembers.
# makeroc2, a SAM program which plots the number of false negatives
# and false positives is run on each pair of distance files - the title
# is used to identify the pairs.
# All results are plotted onto the same set of axes and a postscript
# graph is generated by gnuplot.  Each curve is labelled with its title.
#
# If the distance files are not in the current directory, absolute path
# names are required.
#
# Usage: multi_roc2.pl <true1.dist> <false1.dist> <title1>
# <true2.dist> <false2.dist> <title2> <true3.dist>
# <false3.dist> <title3> etc.
#--------------------------------------------------------------------------

  if ($#ARGV < 2 ) {&print_usage_exit};

#read in the files and the titles (triples)
  while ( @ARGV ) {
      $next_file = shift(@ARGV);
      &file_check;
      push(@true_files, $next_file);
      $next_file = shift(@ARGV);
      &file_check;
      push(@false_files, $next_file);
#the next one is not a really a file and doesn't need to be checked
      $next_file = shift(@ARGV);
      push(@titles, $next_file);
  }

#run makeroc2 on all the triples
  $i = 0;
  for ( @titles ) {
      system "makeroc2 $titles[$i] -Nllfile $true_files[$i] -Nllfile2 $false_files[$i] -plotps 0"; 
      system "rm $titles[$i].plt";
      $i++;
  }

  $_ = `pwd`;
  (/.*\/(\S+)\s*\n?/) && ($cwd = $1);

# prepare a gnuplot .plt file
  &new_pltfile;

#make the ps file
  system "gnuplot multi.plt";

  exit (1);

#----------------------- subroutines ----------------------------

sub print_usage_exit {
print "\n\n";
print "  Function: takes triples of two distance files and a title\n";
print "            the two distance families are scores for family\n";
print "            and non-family members and title is family name\n";
print "            or identifier of your choice\n";
print "            Outputs a gnu-plot graph in ps format showing \n";
print "            number of false negatives vs. number of false positives \n"
;
print "            for each family\n";
print "\n";
print "  Usage: multi_roc2.pl <true1.dist> <false1.dist> <title1>\n";
print "  optional:            <true2.dist> <false2.dist> <title2>\n";
print "  Note: you can enter as many triples as you wish.\n\n";
exit (-1);
}

#new_pltfile creates a gnuplot .plt file (to be converted to postscript)
sub new_pltfile {
  $plotfile = "multi.plt";
  open( PLOTFILE, ">$plotfile" ) || die "Can't open $plotfile.\n";
  print( PLOTFILE "# set terminal postscript eps\n");
  print( PLOTFILE "# set output \"multi.ps\"\n");
  print( PLOTFILE "set title \"False Postives vs. False Negatives ($cwd)\"\n");
  print( PLOTFILE "set xlabel \"False Negatives\"\n");
  print( PLOTFILE "set ylabel \"False Positives\"\n");
  print( PLOTFILE "set nozeroaxis\n");
  $i = 1;
  for ( @titles ) {
    $datafile = "$_"."1.data";
#$#titles is adjusted for off by one
    if ( $i == 1 && ($#titles + 1 ) == 1 ) {
      print( PLOTFILE "plot \"$datafile\" title \"$_\" with lines\n" ); 
    } elsif ( $i == 1 ) {
      print( PLOTFILE "plot \"$datafile\" title \"$_\" with lines,\\\n" );
    } elsif ( $i == ($#titles + 1) ) { 
      print ( PLOTFILE "    \"$datafile\" title \"$_\" with lines\n");
    } else {
      print ( PLOTFILE "    \"$datafile\" title \"$_\" with lines,\\\n");
    }
  $i++;
  }
  close (PLOTFILE);
}

#------------------------ error checking routines-------------------------

# file_check checks that the file exists in the current directory
# and that it is a distance file
sub file_check {
    if ( -e $next_file != 1 ) {
        print "Error: $next_file does not exist.  Exiting . . .\n\n";
        exit(2);
    }
     if ( $next_file !~ /\.dist/ ) {
        print "Error: $next_file not a distance file.  Exiting . . . \n\n";
        exit(2);
    }
}





