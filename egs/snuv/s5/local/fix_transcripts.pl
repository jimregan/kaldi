#!/usr/bin/perl
# Fix transcripts
# Copyright 2017  Jim O'Regan
# Apache 2.0

use warnings;
use strict;
use utf8;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

my %fix = (
  "be" => "b",
  "ce" => "c",
  "ći" => "ć",
  "cy" => "c",
  "de" => "d",
  "dy" => "d",
  "ef" => "f",
  "el" => "l",
  "eł" => "ł",
  "em" => "m",
  "en" => "n",
  "eń" => "ń",
  "er" => "r",
  "es" => "s",
  "eś" => "ś",
  "fy" => "f",
  "gie" => "g",
  "gy" => "g",
  "ha" => "h",
  "hy" => "h",
  "igrek" => "y",
  "ji" => "j",
  "jot" => "j",
  "ka" => "k",
  "ky" => "k",
  "ly" => "l",
  "ły" => "ł",
  "my" => "m",
  "ńi" => "ń",
  "ny" => "n",
  "pe" => "p",
  "py" => "p",
  "ry" => "r",
  "śi" => "ś",
  "sy" => "s",
  "te" => "t",
  "ty" => "t",
  "wu" => "w",
  "wy" => "w",
  "zet" => "z",
  "żet" => "ż",
  "źi" => "ź",
  "źiet" => "ź",
  "zy" => "z",
  "ży" => "ż",
);

sub fix_word {
  my $in = shift;
  if(exists $fix{$in}) {
    return $fix{$in};
  } else {
    return $in;
  }
}

while(<>) {
  chomp;
  s/[()]//g;
  my @words = map { fix_word($_) } split/ /;
  print join(" ", @words) . "\n";
}
