#!/usr/bin/env bash

# get path of root dir of the repo (https://stackoverflow.com/a/246128)
# this is done so that this command can be invoked from any location
# (not only the root of the repo)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. >/dev/null 2>&1 && pwd )"
REPO="${PWD##*/}"
STAGE="$1"

get_pattern()
{
  local_stage=$1
  pattern=""
  case "$local_stage" in
    "dev") pattern="^develop$";;
    "pre") pattern="^release/$";;
    "prod") pattern="^master$";;
  esac
  echo $pattern
}

create_trigger()
{
    _repo=$1
    _stage=$2
    gcloud beta builds triggers create cloud-source-repositories \
      --repo=$_repo \
      --branch-pattern="$(get_pattern $_stage)" \
      --build-config="cloudbuild-$_stage.yaml" \
      --name="$_repo-$_stage" \
      --description="$_stage: $_repo" \
      --substitutions=_STAGE=$_stage
}

if [ "$STAGE" = "prod" -o "$STAGE" = "dev" -o "$STAGE" = "pre" ];
then
  create_trigger $REPO $STAGE
elif [ "$STAGE" = "all" ];
then
    for _stage in dev pre prod;
    do
      create_trigger $REPO $_stage
    done
else
  echo "[!!!] ERROR: Parameter must be [dev/pre/prod]: '$STAGE' was given"
fi