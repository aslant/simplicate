#!/bin/bash

OPTIND=1;
continuous=0;
verbose=0;
bad_opt=0;

while getopts ":s:t:d:f:q:cont:v" o; do
  case "${o}" in
    s)
      src=${OPTARG};
      ;;
    t)
      tar=${OPTARG};
      ;;
    d)
      doc_ids=${OPTARG};
      ;;
    f)
      filter=${OPTARG};
      ;;
    q)
      query_params=${OPTARG};
      ;;
    c)
      continuous=1;
      ;;
    v)
      verbose=1;
      ;;
    *)
      bad_opt=1;
      break;
      ;;
  esac
done

if [ $bad_opt -eq 0 ]; then
  shift $((OPTIND-1));
  url=$1;
  OPTIND=1; # cleanup
fi

if [ -z "$url" ]; then
  url="http://127.0.0.1:5984";
fi

if [ -z "$src" ] && [ -z "$tar" ] || [ -z "$url" ]; then
  OPTIND=1; # cleanup
  usage_txt_path=$(dirname $(readlink $0))/usage.txt;
  if [[ $usage_txt_path =~ ^[^/] ]]; then
    # relative path
    usage_txt_path=$(dirname $0)/$usage_txt_path;
  fi

  printf "$(cat $usage_txt_path)";
fi

if [ -z "$tar" ]; then
  tar=`echo $src | perl -pe "s|.*?([^/]*)/?$|\1|"`;
fi

if [ -z "$src" ]; then
  src=`echo $tar | perl -pe "s|.*?([^/]*)/?$|\1|"`;
fi

body="{\"create_target\":true",\"source\":\"${src}\",\"target\":\"${tar}\"

if [ -n "$doc_ids" ]; then
  body="${body},\"doc_ids\":${doc_ids}";
fi

if [ -n "$filter" ]; then
  body="${body},\"filter\":\"${filter}\"";
fi

if [ -n "$query_params" ]; then
  body="${body},\"query_params\":\"${query_params}\"";
fi

if [ "$continuous" -eq 1 ]; then
  body="${body},\"continuous\":true";
fi

body="${body}}";

cmd="curl" && [ $verbose -eq 1 ] && cmd="curl -v"
cmd="${cmd} -H 'Content-Type: application/json' -X POST ${url}/_replicate -d '${body}'"
echo;
echo "  $cmd";
echo;

read -r -p "execute command? [y/N]" response
if [[ $response =~ ^[yY]$ ]]; then
  echo `eval ${cmd}`
else
  exit 1
fi
