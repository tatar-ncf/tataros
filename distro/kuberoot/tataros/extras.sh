# shellcheck shell=sh disable=SC2154 # $OUT and $r come from build-rootfs.sh
# Sourced by kuberoot's build-rootfs.sh: TatarOS on the node. hack/kuberoot.sh
# builds tataros-banner and renders the banner into $OUT/tataros.
install -m 0755 "$OUT/tataros/tataros-banner" "$r/usr/bin/tataros-banner"
install -D -m 0644 "$OUT/tataros/banner.txt" "$r/usr/share/tataros/banner.txt"
