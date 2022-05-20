#!/usr/bin/perl
# Arguments: datafile sizesfile #chromosomes
#
# The sizesfile should look like should show a chromosome number followed
# by a number of columns, like:
# 1 440212
# 2 473669
# ...
# 22 82139

if (!($ARGV[0] =~ /.*\.data$/)) {
        die "Error: File name must end with .data!\n";
        exit;
}

$basefn = $ARGV[0];
$basefn =~ s/\.data$//;

open(DATAFILE, $ARGV[0]) || die "Error: Cannot open $ARGV[0]\n";
open(SIZES, $ARGV[1]) || die "Error: Cannot open $ARGV[1]\n";
while(<SIZES>) {
        chomp;
        ($chr, $n) = split;
        $size[$chr] = $n;
}
close(SIZES);

$endcol[0] = -1;
foreach $i (1..$ARGV[2]) {
        $startcol[$i] = $endcol[$i-1] + 1;
        $endcol[$i] = $startcol[$i] + $size[$i] - 1;
        if($startcol[$i] < $endcol[$i]) {print "$i, $startcol[$i], $endcol[$i]\n";}
        $fname = $basefn . "_chr" . $i . ".data";
        open($fh[$i], ">$fname") || die "Error: Cannot open $fname for writing!\n";
}

while(<DATAFILE>) {
        chomp;
        @f = split;
        foreach $i (1..$ARGV[2]) {
                $fhandle = $fh[$i];
                print $fhandle join(" ", @f[$startcol[$i]..$endcol[$i]]), "\n";
        }
}

foreach $i (1..$ARGV[2]) {
        close($fh[$i]);
}
