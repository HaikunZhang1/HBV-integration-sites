#!/usr/bin/perl
use strict;
use warnings;

######    extract integration site of cutoff   #####

open(IN,"$ARGV[0]");     #/asnas/zengchq_group/zhanghk/HBVinteg_trascriptome/5-HBVintegration/R02242/HBV_integration_site_pair_depth.txt
open(OUT,">$ARGV[2]");    #/asnas/zengchq_group/zhanghk/HBVinteg_trascriptome/5-HBVintegration/R02242/HBV_integration_site_pair10.txt
my ($line, @line, $cutoff, %cutoff);

while ($line = <IN>) {
	chomp($line);
	$line =~ s/\r//;
	@line = split("\t",$line);
	if (($line[1] eq "NA") and ($line[4] >= "$ARGV[1]")){
		$cutoff = "$line[0]\t$line[1]\t$line[2]";
		$cutoff{$cutoff} = "$line[3]\t$line[4]";
	}
	if (($line[2] eq "NA") and ($line[3] >= "$ARGV[1]")){
		$cutoff = "$line[0]\t$line[1]\t$line[2]";
		$cutoff{$cutoff} = "$line[3]\t$line[4]";
	}	
	if (($line[1] ne "NA") and ($line[2] ne "NA")){
		if (($line[3] >= "$ARGV[1]") and ($line[4] >= "$ARGV[1]")){
		$cutoff = "$line[0]\t$line[1]\t$line[2]";
		$cutoff{$cutoff} = "$line[3]\t$line[4]";
		}
		if (($line[3] < "$ARGV[1]") and ($line[4] >= "$ARGV[1]")){
		$cutoff = "$line[0]\tNA\t$line[2]";
		$cutoff{$cutoff} = "NA\t$line[4]";
		}
		if (($line[3] >= "$ARGV[1]") and ($line[4] < "$ARGV[1]")){
		$cutoff = "$line[0]\t$line[1]\tNA";
		$cutoff{$cutoff} = "$line[3]\tNA";
		}
	}
}

my ($Pos, $PB, $key, @key, %Pos, %PB);
foreach $key (sort{ $a cmp $b } keys %cutoff) {
	@key = split("\t",$key);
	if ($key[1] ne "NA"){
		$Pos = "$key[0]\t$key[1]";
		$Pos{$Pos}++;
	}
	if ($key[2] ne "NA") {
		$PB = "$key[0]\t$key[2]";
		$PB{$PB}++;
	}
}
foreach $key (sort{ $a cmp $b } keys %cutoff) {
	@key = split("\t",$key);
	$Pos = "$key[0]\t$key[1]";
	$PB = "$key[0]\t$key[2]";
	next if (($key[1] eq "NA") and ($PB{$PB} >1));
	next if (($key[2] eq "NA") and ($Pos{$Pos} >1));
	print OUT "$key\t$cutoff{$key}\n";
}

close(IN);
close(OUT);
