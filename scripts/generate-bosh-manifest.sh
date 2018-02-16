#!/usr/bin/env bash

dir="$(cd "$( dirname $0)" && pwd)"
cfdev_ops="$dir"/../images/cf-oss/bosh-operations/
output_dir="$dir"/../build
mkdir -p "$output_dir"

set -ex

while getopts "b:" arg; do
  case $arg in
    b) bosh_deployment="$OPTARG"
      ;;
  esac
done

if [[ "$bosh_deployment" = "" ]]; then
  echo "USAGE ./generate-manifest -c <path-to-bosh-deployment>"
fi
bosh_deployment_version="$(git -C "$bosh_deployment" describe --tags)"

pushd "$bosh_deployment" > /dev/null
    bosh int bosh.yml \
      -o bosh-lite.yml \
      -o bosh-lite-runc.yml \
      -o bosh-lite-grootfs.yml \
      -o warden/cpi.yml \
      -o warden/cpi-grootfs.yml \
      -o jumpbox-user.yml \
      \
      -o "$cfdev_ops"/disable-app-armor.yml \
      -o "$cfdev_ops"/remove-ports.yml \
      -o "$cfdev_ops"/use-warden-cpi-v39.yml \
      -o use-stemcell-3468.17.yml \
      \
      -v director_name="warden" \
      -v internal_cidr=10.245.0.0/24 \
      -v internal_gw=10.245.0.1 \
      -v internal_ip=10.245.0.2 \
      -v garden_host=10.0.0.10 \
      > "$output_dir/bosh-$bosh_deployment_version.yml"
popd
