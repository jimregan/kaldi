#!/bin/bash

# Copyright   2014  Johns Hopkins University (author: Daniel Povey)
#             2017  Luminar Technologies, Inc. (author: Daniel Galvez)
#             2017  Ewald Enzinger
#             2017  Jim O'Regan
# Apache 2.0

# Adapted from egs/commonvoice/s5/local/download_and_untar.sh (commit 93ceca70029c4fe1d572b9c03756b5fc3ae00886)

remove_archive=false

if [ "$1" == --remove-archive ]; then
  remove_archive=true
  shift
fi

if [ $# -ne 2 ]; then
  echo "Usage: $0 [--remove-archive] <data-base> <url> <subdir> <expected-size>"
  echo "e.g.: $0 /export/data/ http://pelcra.pl/resources/spoken/snuv.tar.gz snuv 24149006957"
  echo "With --remove-archive it will remove the archive after successfully un-tarring it."
fi

data=$1
url=$2
subdir=$3
filesize=$4

if [ ! -d "$data" ]; then
  echo "$0: no such directory $data"
  exit 1;
fi

if [ -z "$url" ]; then
  echo "$0: empty URL."
  exit 1;
fi

if [ -f $data/$subdir/.complete ]; then
  echo "$0: data was already successfully extracted, nothing to do."
  exit 0;
fi

archivename=$(echo $url|awk -F/ '{print $NF}')
filepath="$data/$archivename"

if [ -f $filepath ]; then
  size=$(/bin/ls -l $filepath | awk '{print $5}')
  size_ok=false
  if [ "$filesize" -eq "$size" ]; then size_ok=true; fi;
  if ! $size_ok; then
    echo "$0: removing existing file $filepath because its size in bytes ($size)"
    echo "does not equal the size of the archives ($filesize)."
    rm $filepath
  else
    echo "$filepath exists and appears to be complete."
  fi
fi

if [ ! -f $filepath ]; then
  if ! which wget >/dev/null; then
    echo "$0: wget is not installed."
    exit 1;
  fi
  echo "$0: downloading data from $url.  This may take some time, please be patient."

  cd $data
  if ! wget --no-check-certificate $url -O $filepath; then
    echo "$0: error executing wget $url"
    exit 1;
  fi
fi

cd $data

if ! tar -xzf $filepath; then
  echo "$0: error un-tarring archive $filepath"
  exit 1;
fi

touch $data/$subdir/.complete

echo "$0: Successfully downloaded and un-tarred $filepath"

if $remove_archive; then
  echo "$0: removing $filepath file since --remove-archive option was supplied."
  rm $filepath
fi
