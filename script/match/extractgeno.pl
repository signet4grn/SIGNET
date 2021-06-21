#!/usr/bin/perl
# extractrgeno.pl file
my @IDX;
open(IDXLIST, $ARGV[0]) || die "Couldn't open $ARGV[0]\n";
while(<IDXLIST>) {
chomp;
push(@IDX,$_);
}
close(IDXLIST);

$linescount=1;
open(MAP, $ARGV[1]) || die "Couldn't open $ARGV[1]\n";
while(<MAP>) {

while ($linescount eq $IDX[0]) {
print $_;
shift @IDX;
}
$linescount++;
}
