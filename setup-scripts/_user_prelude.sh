#!/bin/echo This script is meant to sourced not executed

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script should only be run in the context of the primary user."
  exit 1
fi

source /etc/os-release

if [ "${NAME}" != "Fedora" ]; then
  echo "These setup scripts are only targetting Fedora. It looks like you're trying to run this on another distro."
  exit 1
fi
