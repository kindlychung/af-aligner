#!/usr/bin/perl

print "This script generates hunalign dictionaries from all txt files found in the current folder. Cd into the folder containing the script and the txt files before running the script. Do not run from any other \'current folder\'!\nPress ctrl-c to abort or enter to start.";
<STDIN>;
my @files = <*.txt>;
@files = ("en.txt", "sw.txt", "hu.txt", "hr.txt"); # for testing

unlink "log.log";
open(LOG, ">>:encoding(UTF-8)", "log.log") or print "\nCan't create log file: $!\nContinuing anyway.\n";


my @failed; # collect unavailable lang combos

foreach my $file1 (@files) {

	foreach my $file2  (@files) {

		next if $file1 eq $file2; # let's not make en-en dictionaries

		my $f1 = $file1;		# vars for naming the output file
		$f1 =~ s/\.txt$//i;
		my $f2 = $file2;
		$f2 =~ s/\.txt$//i;

		open(DIC1, "<:encoding(UTF-8)", "$file1") or print "Can't open dictionary file: $!" or die "can't open file: $!";
		open(DIC2, "<:encoding(UTF-8)", "$file2") or print "Can't open dictionary file: $!" or  die "can't open file: $!";
		open(DIC, ">:encoding(UTF-8)", "${f1}-${f2}.dic") or print "Can't open dictionary file: $!" or  die "can't open file: $!";

		print "\n\nGenerating ${f1}-${f2} dictionary... ";
		print LOG "\nGenerating ${f1}-${f2} dictionary... ";

		my %seen; # for filtering out dupes
		until( eof(DIC1) and eof (DIC2)) { # generate a .dic file from two word lists
			my $col_1 = <DIC1>;
			my $col_2 = <DIC2>;
			chomp($col_1);
			chomp($col_2);
			next if $col_1 eq ""; # skip incomplete records
			next if $col_2 eq "";
			my $record = "$col_2 @ $col_1"; # hunalign takes dictionaries in reverse order!
			print DIC "$record\n" if (! $seen{ $record }++); # add record to hash as key, occurrence no. as value. If not yet in hash, print to DIC
		}
		close DIC1;
		close DIC2;
		close DIC;

		my $dicsize = keys %seen;
		if ($dicsize == 0) {
			unlink "${f1}-${f2}.dic"; # get rid of the empty file
			print "Language combination not available\n";
			print LOG "Language combination not available\n";
			push (@failed, "${f1}-${f2}"); # for reporting
		} else {
			print "Dictionary generated containing $dicsize entries\n";
			print LOG "Dictionary generated containing $dicsize entries\n";
		}

	}

}

print "\n\nUnavailable combinations: @failed";
print LOG "\n\nUnavailable combinations: @failed";
close LOG;


print "\n\nPress enter to quit.\n";
<STDIN>;