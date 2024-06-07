#!/usr/bin/perl
use strict;
use warnings;

######    extract the HBV integration sites from sam file   #####

open(IN,"$ARGV[0]");     #/asnas/zengchq_group/zhanghk/HBVinteg_trascriptome/3-BWA/R02242/HBV.sam
open(OUT,">$ARGV[1]");    #/asnas/zengchq_group/zhanghk/HBVinteg_trascriptome/3-BWA/R02242/HBV_integration_site_depth.txt
my ($line, @line, $position_Pos, $position_PB, $site_human_Pos, $site_human_PB, $site_human, %site_human_Pos, %site_human_PB, %site_human, $key_Pos, $key_PB, $key, @key_Pos, @key_PB);

# extract the integration site from sam file: Pos and PB two types
while ($line = <IN>) {
	chomp($line);
	$line =~ s/\r//;
	@line = split("\t",$line);
	next if (($line =~ /(^\@SQ)|(^\@PG)/)); # skip the head of sam file
	if ($line =~ /(SA:Z.*;)/) {   # soft/hard clip, when this read map long, alternative do not have SA:Z tag
		my @SA = split(":",$1);                
		my @ref = split(",",$SA[2]);
		if (($line[2] =~ /chr[0-9]*/) and ($line[5] =~ /S|H/) and ($ref[0] !~ /chr[0-9]*/)) { # $ref[0] !~ /chr[0-9]*/ exclude the read that alternative both to chr
			if (($line[5] =~ /^([0-9]*)S/) or ($line[5] =~ /^([0-9]*)H/)) {  # the site is right (PB)
				$position_PB =  $line[3];	
				$site_human_PB = "$line[2]\t$position_PB";
				if (exists $site_human_PB{$site_human_PB}){
    				$site_human_PB{$site_human_PB}++;    
    			} else {
    				$site_human_PB{$site_human_PB} = 1;
    			}
			}
			if ($line[5] =~ /^([0-9]*)M/) { # the site is left (Pos)
				$position_Pos = $line[3] + $1 - 1;	
				$site_human_Pos = "$line[2]\t$position_Pos";
				if (exists $site_human_Pos{$site_human_Pos}){
    				$site_human_Pos{$site_human_Pos}++;    
    			} else {
    				$site_human_Pos{$site_human_Pos} = 1;
    			}
			} 
		}
	} else {     # soft/hard clip, when this read map long, alternative do not have SA:Z tag
		if (($line[2] =~ /chr[0-9]*/) and ($line[5] =~ /S|H/)) {
			if (($line[5] =~ /^([0-9]*)S/) or ($line[5] =~ /^([0-9]*)H/)) {
				$position_PB =  $line[3];	
				$site_human_PB = "$line[2]\t$position_PB";
				if (exists $site_human_PB{$site_human_PB}){
    				$site_human_PB{$site_human_PB}++;    
    			} else {
    				$site_human_PB{$site_human_PB} = 1;
    			}
			}
			if ($line[5] =~ /^([0-9]*)M/) {
				$position_Pos = $line[3] + $1 - 1;	
				$site_human_Pos = "$line[2]\t$position_Pos";
				if (exists $site_human_Pos{$site_human_Pos}){
    				$site_human_Pos{$site_human_Pos}++;    
    			} else {
    				$site_human_Pos{$site_human_Pos} = 1;
    			}
			} 
		}
	}
}

# merge Pos and PB (one intergaration event)
foreach $key_Pos (sort{ $a cmp $b } keys %site_human_Pos) { 
	#next if ($site_human_Pos{$key_Pos} < "$ARGV[1]");
	@key_Pos = split("\t",$key_Pos);
	my $count = 0;
	foreach $key_PB (keys %site_human_PB) {
		#next if ($site_human_PB{$key_PB} < "$ARGV[1]");
		@key_PB = split("\t",$key_PB);
		if (($key_Pos[0] eq $key_PB[0]) and (($key_PB[1] - $key_Pos[1]) <= 20000) and (($key_PB[1] - $key_Pos[1]) > 0)) {
			$site_human = "$key_Pos\t$key_PB[1]";
			$site_human{$site_human} = "$site_human_Pos{$key_Pos}\t$site_human_PB{$key_PB}";
			$count++;
		}	
	}
	if ($count == 0) {
		$site_human = "$key_Pos\tNA";
		$site_human{$site_human} = "$site_human_Pos{$key_Pos}\tNA";
	}
}
foreach $key_PB (sort{ $a cmp $b } keys %site_human_PB) {
	#next if ($site_human_PB{$key_PB} < "$ARGV[1]");
	@key_PB = split("\t",$key_PB);
	my $count = 0;
	foreach $key_Pos (keys %site_human_Pos) {
		#next if ($site_human_Pos{$key_Pos} < "$ARGV[1]");
		@key_Pos = split("\t",$key_Pos);
		if (($key_Pos[0] eq $key_PB[0]) and (($key_PB[1] - $key_Pos[1]) <= 20000) and (($key_PB[1] - $key_Pos[1]) > 0)) {
			$site_human = "$key_PB[0]\t$key_Pos[1]\t$key_PB[1]";
			$site_human{$site_human} = "$site_human_Pos{$key_Pos}\t$site_human_PB{$key_PB}";
			$count++;
		}	
	}
	if ($count == 0) {
		$site_human = "$key_PB[0]\tNA\t$key_PB[1]";
		$site_human{$site_human} = "NA\t$site_human_PB{$key_PB}";
	}
}

foreach $key (sort{ $a cmp $b } keys %site_human) {
	print OUT "$key\t$site_human{$key}\n";
}

close(IN);
close(OUT);
