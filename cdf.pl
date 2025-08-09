#!/usr/bin/perl

#
# tzoompy: April 2001
#          Thank God for Perl
#

use Getopt::Std;

getopts('f:');

$file = $opt_f;

# This script assumes that each line contains a single number
# If that's not the case, it refuses to continue. Please clean the data first
if ($file =~ /.gz$/i) {
    open TMP, "-|", "gzip -dc ".$file or die "gzip -dc failed for $file: $!";
} else {
    open TMP, "<".$file || die "Can't open file".$file;
}
$lines = 0;
while(<TMP>) {
    $line = $_;
    if ($line =~ /^[0-9,\.]+$/) {
        $lines += 1;
    }   
    else {
        die "Line $lines is not a number";
    }
}
close TMP;

# Open the file sorted numerically
if ($file =~ /.gz$/i) {
    open TMP, "-|", "gzip -dc ".$file." | sort -n" or die "gzip -dc failed for $file: $!";
} else {
    open TMP, "sort -n ".$file." |" || die "Can't open file";
}

# We like to print the CDF as a step function
# Given two consecutive points on the CDF (x1, y1) and (x2, y2)
# we print (x1, y1) (x2, y1) (x2, y2)
$old_y = 0;
$count = 0;
$current_x = "";
while(<TMP>) {    
    $line = $_;
    if ($line =~ /\s/) {
        chop($line);
        # If not the first line
        if ($current_x cmp "") {
            # If line is different than predecessor, print CDF point
            if ($current_x cmp $line) {
        	    printf("%.2f\t%.2f\n", ($current_x),($old_y));
        	    printf("%.2f\t%.2f\n", ($current_x),($count)/$lines);
                $old_y = ($count) / $lines;
            }
        }

        $count += 1;
        $current_x = $line;
    }
}

# Last point in CDF to print
printf("%.2f\t%.2f\n", ($current_x),($old_y));
printf("%.2f\t%.2f\n", ($current_x),($count)/$lines);

close TMP;

