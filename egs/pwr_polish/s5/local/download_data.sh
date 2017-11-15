#!/bin/bash
# Copyright 2017 Jim O'Regan
# Apache 2.0

data=$1
base_url="https://www.ii.pwr.edu.pl/~sas/ASR/data"

check_size() {
  case $1 in
    "AM_Train_sng_male.zip") echo "595999813";;
    "SWD.zip") echo "356192614";;
    "VIUs.zip") echo "96381196";;
    *) echo "";;
  esac
}

download_file() {
  url=$1
  output=$2
  echo $1 $2
  if [ ! -z "$(which wget)" ]; then
    wget --no-check-certificate $url -O $output
  elif [ ! -z "$(which curl)" ]; then
    curl $url -o $output
  else
    echo "$0: neither wget nor curl is installed."
    exit 1;
  fi
}

mkdir -p $data

for i in "AM_Train_sng_male" "SWD" "VIUs"; do
  filename=$i.zip
  
  if [ -f $data/$filename ]; then
    size=$(/bin/ls -l $data/$filename | awk '{print $5}')
    size_expected=$(checksize $filename)
    if [ $size == $size_expected ]; then
      echo "$data/$filename exists and appears to be complete."
    esle
      echo "$0: removing existing file $data/$filename because its size in bytes $size"
      echo "does not equal the expected size $size_expected"
      rm $data/$filename
    fi
  fi

  if [ ! -f $data/$filename ]; then
    download_file $base_url/$filename $data/$filename
  fi

  # the PWR zip files have no directory structure
  if [ ! -d $data/$i ]; then
    mkdir -p $data/$i
  fi
  pushd $data/$i
    unzip ../$filename || exit 1
  popd
done