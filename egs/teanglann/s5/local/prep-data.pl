#!/usr/bin/perl

use warnings;
use strict;
use utf8;

use URI::Escape;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

my %fixU = (
    'éigin' => 'inteacht',
    'a Dhia' => 'Dhia',
    'a fhad le' => 'fhad le',
);
my %fixC = (
    'éigin' => 'eicint',
    'zúmáil' => 'súmáil',
    'zúm' => 'súm',
    'zipeáil' => 'sipeáil',
    'zip' => 'sip',
    #vótóir = wótóir

);
my %fixM = (
    'éigin' => 'éigint',
    'fáil' => 'fáilt',
    'a fhad le' => 'fad le',
    # zónáilte = zónáilthe
);

sub get_replacement {
    my $word = $_[0];
    my $dialect = $_[1];
    if ($dialect eq 'M') {
        if(exists $fixM{$word}) {
            return $fixM{$word};
        } else {
            return $word;
        }
    }
    if ($dialect eq 'U') {
        if(exists $fixU{$word}) {
            return $fixU{$word};
        } else {
            return $word;
        }
    }
    if ($dialect eq 'C') {
        if(exists $fixC{$word}) {
            return $fixC{$word};
        } else {
            return $word;
        }
    }
}

sub irish_lc {
    my $text = shift;
    $text =~ s/^([nt])([AEIOUÁÉÍÓÚ].*)/$1-$2/;
    return lc($text);
}

sub tolower {
    my $text = $_[0];
    my @pieces = split / /, $text;
    my @lcpieces = map { irish_lc($_) } @pieces;
    return join(" ", @lcpieces);
}

sub clean {
    my $in = shift;
    my $lwr = tolower($in);
    $lwr =~ s/[!]//g;
    return $lwr;
}

my $out = 1;
my $spk = 1;

if (! -d "audio") {
    mkdir "audio";
}
if (! -d "data") {
    mkdir "data";
}
if (! -d "data/train") {
    mkdir "data/train";
}

open(UTT, '>', 'data/train/utt2spk');
open(TEXT, '>', 'data/train/text');
binmode(TEXT, ":utf8");
open(URLS, '>', 'audio/urls');
open(WAVSCP, '>', 'data/train/wav.scp');
binmode(WAVSCP, ":utf8");

my %spkutt = ();

while(<>) {
    chomp;
    my $dialect = '';
    my ($file, $speaker) = split/\t/;
    if (!defined $speaker || $speaker eq '') {
        $speaker = sprintf("unk%06d", $spk);
        $spk++;
    }

    my $utt = sprintf("%s-%06d", $speaker, $out);
    print UTT "$utt $spk\n";

    if(exists $spkutt{$speaker}) {
        $spkutt{$speaker} .= " $utt";
    } else {
        $spkutt{$speaker} = $utt;
    }

    if ($file =~ /\/Can([CUM])\//) {
        $dialect = $1;
    }
    my $base = $file;
    $base =~ s/\.mp3$//;
    my $text = '';

    print WAVSCP "$utt sox \"$file\" -t wav - |\n";

    if($base =~ /\/([^\/]*)$/) {
        $text = $1;
    }
    print URLS "http://www.teanglann.ie/Can$dialect/" . uri_escape_utf8($text) . ".mp3\n";

    my $outtext = '';
    if(/éigin$/) {
        if($dialect ne 'M' || ($dialect eq 'M' && ($text ne 'éigin' && $text ne 'am éigin'))) {
            my $replacement = get_replacement('éigin', $dialect);
            $text =~ s/éigin/$replacement/;
            $outtext = clean("$text");
        } else {
            $outtext = clean("$text");
        }
    } else {
        $outtext = clean(get_replacement($text, $dialect));
    }
    print TEXT "$utt\t$outtext\n";
    $out++;
}
