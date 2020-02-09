#!/bin/bash
mkdir -p $2;

echo "running warmup...";
warmup_concurrency=1000
warmup_result="$2/warmup.json"
docker run -ti --rm --network=host --ulimit nofile=20000:40000 alpine/bombardier --http2 -o json -p result -c $warmup_concurrency -n 50000 -t 60s -l $1 | jq '.' | tee $warmup_result > /dev/null;
echo "concurrency=$warmup_concurrency, timeTakenSeconds=$(cat $warmup_result | jq '.result.timeTakenSeconds'), rps=$(cat $warmup_result | jq '.result.rps.mean')"
sleep 5;

inputs=( "$@" )
concurrency=( "${inputs[@]:2}" )

for value in "${concurrency[@]}"
do
  json_result="$2/c$value.json"
  echo "running concurrency = $value";
  docker run -ti --rm --network=host --ulimit nofile=20000:40000 alpine/bombardier --http2 -o json -p result -c $value -n 300000 -t 60s -l $1 | jq '.' | tee $json_result > /dev/null;
  echo "concurrency=$value, timeTakenSeconds=$(cat $json_result | jq '.result.timeTakenSeconds'), rps=$(cat $json_result | jq '.result.rps.mean')"
  sleep 5;
done
