"""Turns kuberoot's edge profile into TatarOS': the same node, with
tataros-banner as the first service of every role. It greets the console in
Tatar when kinit starts the node's services and then waits, so kinit never
counts it as restarting. Nothing in kuberoot's core changes.

Usage: profile.py EDGE_PROFILE > PROFILE"""
import sys

text = open(sys.argv[1]).read()
if "\n  name: edge\n" not in text:
    sys.exit("profile of edge changed: no metadata.name to replace")
text = text.replace("\n  name: edge\n", "\n  name: tataros\n", 1)

services = "\n      services:\n"
if text.count(services) != 2:
    sys.exit("profile of edge changed: expected the services of two roles")
banner = """      - name: tataros-banner
        args: [/usr/bin/tataros-banner, --banner=/usr/share/tataros/banner.txt]
"""
text = text.replace(services, services + banner)
sys.stdout.write(text)
