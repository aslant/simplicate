#!/bin/bash

OPTIND=1
continuous=0
verbose=0
bad_opt=0

while getopts ":s:t:d:f:q:cont:v" o
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
    *)
      bad_opt=1
      break
      ;;
  esac
done

if [ $bad_opt -eq 0 ]
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

[ -z "$tar" ] && tar=$(echo "$src" | perl -pe "s|.*?([^/]*)/?$|\1|")
[ -z "$src" ] && src=$(echo "$tar" | perl -pe "s|.*?([^/]*)/?$|\1|")

body="{\"create_target\":true",\"source\":\"$src\",\"target\":\"$tar\"
[ -n "$doc_ids" ]       && body="$body,\"doc_ids\":$doc_ids"
[ -n "$filter" ]        && body="$body,\"filter\":\"$filter\""
[ -n "$query_params" ]  && body="$body,\"query_params\":$query_params"
[ "$continuous" -eq 1 ] && body="$body,\"continuous\":true"
body="$body}"

cmd="curl"
[ $verbose -eq 1 ] && cmd="curl -v"
cmd="$cmd -H 'Content-Type: application/json' -X POST $url/_replicate -d '$body'"

echo -e "\n  $cmd\n" >&2

read -r -p "execute command? [y/N]" response
if [[ $response =~ ^[yY]$ ]]
then
  echo `eval $cmd`
else
  exit 1
fi
