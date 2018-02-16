#!/usr/bin/env bash

dir="$(cd "$( dirname $0)" && pwd)"
cfdev_ops="$dir"/../images/cf-oss/cf-operations/
output_dir="$dir"/../build
mkdir -p "$output_dir"

set -ex

while getopts "c:" arg; do
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
  bosh int cf-deployment.yml \
  -o operations/use-compiled-releases.yml \
  -o operations/enable-privileged-container-support.yml \
  -o operations/experimental/use-grootfs.yml \
  \
  -o operations/experimental/skip-consul-cell-registrations.yml \
  -o operations/experimental/skip-consul-locks.yml \
  -o operations/experimental/use-bosh-dns.yml \
  -o operations/experimental/use-bosh-dns-for-containers.yml \
  -o operations/experimental/disable-consul.yml \
  -o operations/bosh-lite.yml \
  -o operations/experimental/disable-consul-bosh-lite.yml \
  \
  -o "$cfdev_ops"/allow-local-docker-registry.yml \
  -o "$cfdev_ops"/add-host-pcfdev-dns-record.yml \
  -o "$cfdev_ops"/garden-disable-app-armour.yml \
  -o "$cfdev_ops"/collocate-tcp-router.yml \
  -o "$cfdev_ops"/use-btrfs-grootfs.yml \
  -o "$cfdev_ops"/set-cfdev-subnet.yml \
  \
  -v cf_admin_password=admin \
  -v uaa_admin_client_secret=admin-client-secret > "$output_dir/cf-$cf_deployment_version.yml"
popd
