#!/usr/bin/perl
# Arguments: datafile sizesfile #chromosomes
#
# The sizesfile should look like should show a chromosome number followed
# by a number of columns, like:
# 1 440212
# 2 473669
# ...
# 22 82139

if (!($ARGV[0] =~ /.*\.ped$/)) {
        die "Filename must end in .ped\n";
        exit;
}

$basefn = $ARGV[0];
$basefn =~ s/\.ped$//;

open(DATAFILE, $ARGV[0]) || die "Couldn't open $ARGV[0]\n";
open(SIZES, $ARGV[1]) || die "Couldn't open $ARGV[1]\n";
while(<SIZES>) {
        chomp;
        ($chr, $n) = split;
        $size[$chr] = $n;
}
close(SIZES);

$endcol[0] = 0;
foreach $i (1..$ARGV[2]) {
        $startcol[$i] = $endcol[$i-1] + 1;
        $endcol[$i] = $startcol[$i] + (2 * $size[$i]) - 1;
        print "$i, $startcol[$i], $endcol[$i]\n";
        $fname = $basefn . "_chr" . $i . ".ped";
        open($fh[$i], ">$fname") || die "Cannot open $fname for writing\n";
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
