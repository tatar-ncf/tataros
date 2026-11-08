package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestCRLF(t *testing.T) {
	for in, want := range map[string]string{
		"":               "",
		"сәлам\n":        "сәлам\r\n",
		"a\r\nb\nc":      "a\r\nb\r\nc",
		"◆◇◆\n\nТукай\n": "◆◇◆\r\n\r\nТукай\r\n",
	} {
		if got := string(crlf([]byte(in))); got != want {
			t.Errorf("crlf(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestShowWritesTheConsole(t *testing.T) {
	console := filepath.Join(t.TempDir(), "console")
	if err := os.WriteFile(console, nil, 0o600); err != nil {
		t.Fatal(err)
	}
	show([]byte("Исәнмесез!\n"), console)
	got, err := os.ReadFile(console)
	if err != nil {
		t.Fatal(err)
	}
	if string(got) != "Исәнмесез!\r\n" {
		t.Errorf("console got %q", got)
	}
}

func TestShowWithoutConsole(t *testing.T) {
	show([]byte("x\n"), filepath.Join(t.TempDir(), "missing", "console")) // must not panic
}

func TestInstalling(t *testing.T) {
	if !installing("console=ttyS0 kuberoot.mode=install kuberoot.dev") {
		t.Error("the installer's command line was not recognised")
	}
	if installing("console=ttyS0 kuberoot.mode=installed") {
		t.Error("another mode was taken for the installer")
	}
}
