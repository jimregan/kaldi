#!/usr/bin/perl
# Copyright 2017 Jim O'Regan
# Apache 2.0

use warnings;
use strict;
use utf8;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

my $tie = "\N{U+0361}";

while(<>) {
    chomp;
    my ($l, $r) = split /\t/;
    my @chars = split//, $r;
    my $cur;
    my @phones = ();
    for(my $i = 0; $i <= $#chars; $i++) {
        $cur = '';
        next if($i == 0 && $chars[$i] eq 'ʲ');
        $cur .= $chars[$i];
        if((($i + 2) <= $#chars) && $chars[$i+1] eq $tie) {
            $cur .= $chars[$i+1];
            $i++;
            $cur .= $chars[$i+1];
            $i++;
        }
        if((($i + 1) <= $#chars) && $chars[$i+1] eq 'ʲ') {
            $cur .= $chars[$i+1];
            $i++;
        }
        if((($i + 1) <= $#chars) && $chars[$i+1] eq 'ː') {
            $cur .= $chars[$i+1];
            $i++;
        }
        push @phones, $cur;
    }
    my $rout = join(" ", @phones);
    print "$l\t$rout\n";
}