#!/usr/bin/perl
use strict;
use warnings;

######    extract the HBV integration sites from sam file   #####

open(IN1,"$ARGV[0]");     #/asnas/zengchq_group/zhanghk/HBVinteg_trascriptome/5-HBVintegration/R02238/HBVis_single_PlusHBVg.txt
open(IN2,"$ARGV[1]");     #/asnas/zengchq_group/zhanghk/HBVinteg_trascriptome/5-HBVintegration/R02238/HBV_integration_site_pair10.txt
open(OUT,">$ARGV[2]");    #/asnas/zengchq_group/zhanghk/HBVinteg_trascriptome/5-HBVintegration/R02238/HBV_integration_site_pair10_PlusHBVg.txt

my($line, @line, $site_single, $Pos_human, $PB_human, $Pos_HBV, $PB_HBV, %site_single);

while ($line = <IN1>) {
	chomp($line);
	$line =~ s/\r//;
	@line = split("\t",$line);
	$site_single = "$line[0]\t$line[1]";
	$site_single{$site_single} = $line[3];
}

while ($line = <IN2>) {
	chomp($line);
	$line =~ s/\r//;
	@line = split("\t",$line);
	$Pos_human = "$line[0]\t$line[1]";
	$PB_human = "$line[0]\t$line[2]";
	$Pos_HBV = "NA";
	$PB_HBV = "NA";
	if (exists($site_single{$Pos_human})){
		$Pos_HBV = $site_single{$Pos_human};
	}
	if (exists($site_single{$PB_human})){
		$PB_HBV = $site_single{$PB_human};
	}

	print OUT "$line\t$Pos_HBV\t$PB_HBV\n";

}

close(IN1);
close(IN2);
close(OUT);
