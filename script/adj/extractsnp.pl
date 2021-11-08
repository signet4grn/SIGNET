#!/usr/bin/perl
# extractcols.pl file

open(GENELIST, $ARGV[0]) || die "Couldn't open $ARGV[0]\n";
while(<GENELIST>) 
{
chomp;
$int=$_;
push @genes, $int;
}
close(GENELIST);

open(MAP, $ARGV[1]) || die "Couldn't open $ARGV[1]\n";
while(<MAP>) 
{
chomp;
my @cols= split ' ', $_;
foreach $i(@genes)
{
print $cols[$i-1];
print " ";
}
print "\n";
}
