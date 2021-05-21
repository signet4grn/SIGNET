#!/usr/bin/perl
# extractrows.pl file
open(GENELIST, $ARGV[0]) || die "Couldn't open $ARGV[0]\n";
while(<GENELIST>) {
	chomp;
	$genes{$_}++;
}
close(GENELIST);

open(MAP, $ARGV[1]) || die "Couldn't open $ARGV[1]\n";
while(<MAP>) {
	($thisgene, @dummy2)= split;
	if ($genes{$thisgene}) {
		print $_;
	}
}
