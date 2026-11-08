// tataros-banner greets the console of a TatarOS node: kinit starts it as
// the first service of the node, it writes the banner to the console and to
// its own log, and then waits for kinit to stop it. A kinit service that
// exits is restarted, and a node whose services restart fails its upgrade
// probation, so the banner never exits on its own.
package main

import (
	"bytes"
	"flag"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"
)

func main() {
	banner := flag.String("banner", "/usr/share/tataros/banner.txt", "the banner to show")
	console := flag.String("console", "/dev/console", "where the banner goes besides the log")
	flag.Parse()

	// Booted from media, the console belongs to kuberoot's installer screen.
	if cmdline, err := os.ReadFile("/proc/cmdline"); err == nil && installing(string(cmdline)) {
		*console = ""
	}
	if text, err := os.ReadFile(*banner); err != nil {
		log.Printf("no banner: %v", err)
	} else {
		show(text, *console)
	}

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGTERM, os.Interrupt)
	<-stop
}

// show writes the banner to the log and to the console, line by line with
// carriage returns: a console in raw mode does not add them.
func show(text []byte, console string) {
	_, _ = os.Stdout.Write(text)
	if console == "" {
		return
	}
	c, err := os.OpenFile(console, os.O_WRONLY, 0)
	if err != nil {
		log.Printf("console %s: %v", console, err)
		return
	}
	defer c.Close()
	_, _ = c.Write(crlf(text))
}

// installing says whether the kernel command line boots kuberoot's installer.
func installing(cmdline string) bool {
	for _, arg := range strings.Fields(cmdline) {
		if arg == "kuberoot.mode=install" {
			return true
		}
	}
	return false
}

// crlf ends every line with "\r\n", whether it ended with "\n" or "\r\n".
func crlf(text []byte) []byte {
	text = bytes.ReplaceAll(text, []byte("\r\n"), []byte("\n"))
	return bytes.ReplaceAll(text, []byte("\n"), []byte("\r\n"))
}
