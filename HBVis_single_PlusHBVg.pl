#!/usr/bin/perl
use strict;
use warnings;

######    extract the HBV integration sites from sam file   #####

open(IN,"$ARGV[0]");     #/asnas/zengchq_group/zhanghk/HBVinteg_trascriptome/3-BWA/R02242/HBV.sam
open(OUT,">$ARGV[1]");    #/asnas/zengchq_group/zhanghk/HBVinteg_trascriptome/3-BWA/R02242/HBV_integration_site.txt
my($line, @line, $position_human, $site_human, %site_human, @SA, @HBV, $position_HBV, $site_HBV, $site, %site, %length, %site_max);

while ($line = <IN>) {
	chomp($line);
	$line =~ s/\r//;
	@line = split("\t",$line);

	next if (($line =~ /(^\@SQ)|(^\@PG)/));

	if (($line[2] =~ /chr[0-9]*/) and ($line[5] =~ /S|H/)) {
		next if ($line =~ /(SA:Z:chr)/);
		if (($line[5] =~ /^([0-9]*)S/) or ($line[5] =~ /^([0-9]*)H/)) {
			$position_human = $line[3];	
		}
		if ($line[5] =~ /^([0-9]*)M/) {
			$position_human = $line[3] + $1 - 1;	
		}
		$site_human = "$line[2]\t$position_human";

		if ($line =~ /(SA:Z.*;)/) {
			@SA = split(":",$1);                
			@HBV = split(",",$SA[2]);
			if (($HBV[3] =~ /^([0-9]*)S/) or ($HBV[3] =~ /^([0-9]*)H/)) {
				$position_HBV = $HBV[1];
				$site_HBV = "$HBV[0]\t$position_HBV (-)";
				$site = "$site_human\t$site_HBV";
			}
			if ($HBV[3] =~ /^([0-9]*)M/) {
				$position_HBV = $HBV[1] + $1 - 1;
				$site_HBV = "$HBV[0]\t$position_HBV (+)";
				$site = "$site_human\t$site_HBV";
			}
		} else {
			$site = "$site_human\tundetermined\tundetermined";
		}
		
		if (exists $site{$site}){
    		$site{$site}++;    
    	} else {
    		$site{$site} = 1;
    	}
	}
}

foreach my $key (sort{ $a cmp $b } keys %site) {
	@line = split("\t",$key);
	my $position = "$line[0]\t$line[1]";
	if (!exists($length{$position})){
		$length{$position} = $site{$key};
		$site_max{$position} = "$key\t$site{$key}";
	}else {
		if (($site{$key} > $length{$position}) and ($line[2] ne "undetermined")){
			$length{$position} = $site{$key};
			$site_max{$position} = "$key\t$site{$key}";
		}
	}
}
foreach my $key (sort{ $a cmp $b } keys %site_max) {
	print OUT "$site_max{$key}\n";
}

close(IN);
close(OUT);
