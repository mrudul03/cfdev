#!/usr/bin/env bash

dir="$(cd "$( dirname $0)" && pwd)"
cfdev_ops="$dir"/../images/cf-oss/cf-operations/
output_dir="$dir"/../build
mkdir -p "$output_dir"

set -ex

while getopts "c:s:" arg; do
  case $arg in
    c) cf_deployment="$OPTARG"
      ;;
  esac
done

if [[ "$cf_deployment" = "" ]]; then
  echo "USAGE ./generate-manifest -c <path-to-cf-deployment>"
fi
cf_deployment_version="$(git -C "$cf_deployment" describe --tags)"

pushd "$cf_deployment" > /dev/null
    bosh int iaas-support/bosh-lite/cloud-config.yml \
      -o "$cfdev_ops"/set-cloud-config-subnet.yml > \
      "$output_dir/cloud-config-$cf_deployment_version.yml"
popd
