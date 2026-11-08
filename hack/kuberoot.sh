#!/usr/bin/env bash
# Builds kuberoot as the distribution TatarOS: the sources of kuberoot with
# distros/tataros added (edge's profile with the Tatar console banner as a
# service of every role, the banner and its program in the image), driven by
# kuberoot's own hack/hetzner.sh in a builder of the tenant tataros. Nothing
# heavy runs here: binaries, the image and the media are built in the builder.
#
#   hack/kuberoot.sh build amd64
#   hack/kuberoot.sh bundle amd64
#   hack/kuberoot.sh media amd64 [kernel args]
#   hack/kuberoot.sh node <name> amd64
#   hack/kuberoot.sh console <name>
#
#   KUBEROOT_SRC  a checkout of kuberoot (default: ../kuberoot)
#   KUBEROOT_REF  what of it to build (default: the commit in .upstream-version)
#   NS            the builder's namespace (default: tenant-tataros)
#   BANNER_ALIF   the banner's script: cyrl, latin or arab (default: cyrl)
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=${KUBEROOT_SRC:-$ROOT/../kuberoot}
REF=${KUBEROOT_REF:-$(cat "${ROOT}/.upstream-version")}
NS=${NS:-tenant-tataros}
export KUBECONFIG=${KUBECONFIG_WORKSHOP:-$HOME/workshop.txt}
CTX=${KUBE_CONTEXT:-admin@workshop}

work=$(mktemp -d)
trap 'rm -rf "${work}"' EXIT

git -C "${SRC}" archive "${REF}" | tar -x -C "${work}"
# hetzner.sh ships what git sees
git -C "${work}" init -q

d="${work}/distros/tataros"
mkdir -p "${d}/addons"
python3 "${ROOT}/distro/kuberoot/tataros/profile.py" "${work}/distros/edge/profile.yaml" > "${d}/profile.yaml"
cp "${work}"/distros/edge/addons/* "${d}/addons/"
cp "${ROOT}/distro/kuberoot/tataros/extras.sh" "${d}/"

if [ "${1:-}" = build ]; then
  arch=${2:?arch required}
  # TatarOS' banner and its program, where extras.sh takes them from.
  b() { kubectl --context "$CTX" -n "$NS" exec -i builder -c tools -- "$@"; }
  (cd "${ROOT}" && git ls-files -co --exclude-standard -z | grep -zv '^SESSION_LOG.md$' |
    COPYFILE_DISABLE=1 tar --null -T - -czf -) |
    b sh -c 'rm -rf /work/src/tataros && mkdir -p /work/src/tataros && tar -xzf - -C /work/src/tataros'
  b sh -c "set -e; cd /work/src/tataros; out=/work/out/${arch}/tataros; mkdir -p \$out
    CGO_ENABLED=0 GOARCH=${arch} go build -trimpath -o \$out/tataros-banner ./cmd/tataros-banner
    AYDA_ALIF=${BANNER_ALIF:-cyrl} bash scripts/render-banner.sh > \$out/banner.txt
    ls -la \$out"
fi

KUBEROOT_NS="${NS}" KUBEROOT_DISTRO=tataros "${work}/hack/hetzner.sh" "$@"
