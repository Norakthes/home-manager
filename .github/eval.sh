#!/usr/bin/env bash
# Evaluate every home in the flake. Used by CI, also fine to run locally.
# Only evaluates: building would need the maple installer.
set -euo pipefail

for home in $(nix eval --json .#homeConfigurations --apply builtins.attrNames | jq -r '.[]'); do
  echo "::group::$home"
  nix eval --raw ".#homeConfigurations.\"$home\".activationPackage.drvPath"
  echo
  echo "::endgroup::"
done
