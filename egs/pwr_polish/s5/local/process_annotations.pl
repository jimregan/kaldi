#!/usr/bin/perl
# Copyright 2017 Jim O'Regan
# Apache 2.0

use warnings;
use strict;
use utf8;

my $input = $ARGV[0];
my $base = $input;
$base =~ s![^/]*$!!;

my @raw_duplicates = qw(305846 305363 305278 306094 305982 305685 305838 305672
                    305943 305686 305114 305960 305166 306012 306030 305989
                    305534);
my %duplicates = map { $_ => 1 } @raw_duplicates;

open(IN, '<', $input) or die "$!";
binmode(IN, ":encoding(cp1250)");

while(<IN>) {
    chomp;
    if(/([0-9]*)\.wav *"([^"]*)"/) {
        my $filename = $1;
        my $annotation = $2;
        next if($input =~ m!/SWD/! && exists $duplicates{$filename});
        
        open(OUT, '>', "$base/$filename.txt");
        binmode(OUT, ":utf8");
        print OUT $annotation;
        close OUT;
    }
}
