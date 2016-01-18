#!/bin/bash

OPTIND=1
continuous=
verbose=
yes=
bad_opt=

while getopts ":s:t:d:f:q:cvy" o
do
  case "$o" in
    s)
      src=$OPTARG
      [[ $src =~ ^:[0-9]+/ ]] && src=http://127.0.0.1$src
      ;;
    t)
      tar=$OPTARG
      [[ $tar =~ ^:[0-9]+/ ]] && tar=http://127.0.0.1$tar
      ;;
    d)
      doc_ids=$OPTARG
      ;;
    f)
      filter=$OPTARG
      ;;
    q)
      query_params=$OPTARG
      ;;
    c)
      continuous=1
      ;;
    v)
      verbose=1
      ;;
    y)
      yes=1
      ;;
    *)
      bad_opt=1
      break
      ;;
  esac
done

if [ -z "$bad_opt" ]
then
  shift $((OPTIND-1))
  url=$1
  OPTIND=1; # cleanup
fi

if [ -z "$url" ]
then
  url="http://127.0.0.1:5984"
elif [[ $url =~ ^:[0-9]+ ]]
then
  url=http://127.0.0.1$url
fi

if [ -z "$src" ] && [ -z "$tar" ] || [ -z "$url" ]
then
  OPTIND=1; # cleanup

  symlinktarget="$(readlink "$0")"

  cd "$(dirname "$0")"
  [ -n "$symlinktarget" ] && cd "$(dirname "$symlinktarget")"

  cat usage.txt >&2
  exit 1
fi

[ -z "$tar" ] && tar=$(echo "$src" | perl -pe 's|.*?([^/]*)/?$|\1|')
[ -z "$src" ] && src=$(echo "$tar" | perl -pe 's|.*?([^/]*)/?$|\1|')

body='{"create_target":true,"source":"'"$src"'","target":"'"$tar"'"'
[ -n "$doc_ids" ]       && body="$body"',"doc_ids":'"$doc_ids"
[ -n "$filter" ]        && body="$body"',"filter":"'"$filter"'"'
[ -n "$query_params" ]  && body="$body"',"query_params":'"$query_params"
[ -n "$continuous" ]    && body="$body"',"continuous":true'
body="$body}"

[ -z "$verbose" ] && cmd="curl"
[ -n "$verbose" ] && cmd="curl -v"
cmd="$cmd -s -f --output /dev/null --write-out %{http_code} -H 'Content-Type: application/json' -X POST $url/_replicate -d '$body'"

echo -e "\n  $cmd\n" >&2

if [ -z "$yes" ]
then
  read -r -p "execute command? [y/N]" response
  if [[ ! "$response" =~ ^[yY]$ ]]
  then
    exit 1
  fi
fi

response_code=$(eval "$cmd")
if [ $response_code -ne 200 ]
then
  exit 1
fi
