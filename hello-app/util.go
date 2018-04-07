package main

import (
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

var (
	version string
	started time.Time
	sigs    chan os.Signal
	termed  bool
)

func sigHandler() {
	for sig := range sigs {
		switch sig {
		case syscall.SIGTERM:
			fmt.Println("Received: SIGTERM")
			termed = true
			return
		default:
			fmt.Println("Received:", sig)
		}
	}
}

func init() {
	fmt.Println("Version:", version)
	started = time.Now()
	sigs = make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGTERM)
	go sigHandler()
}

func healthz(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(200)
	w.Write([]byte("ok"))
}

func readiness(w http.ResponseWriter, r *http.Request) {
	errMsg := ""

	if termed {
		errMsg += "Terminated.\n"
		http.Error(w, errMsg, http.StatusServiceUnavailable)
		return
	}

	duration := time.Now().Sub(started)
	if duration.Seconds() < 10 {
		errMsg += "Database not ok.\n"
		http.Error(w, errMsg, http.StatusServiceUnavailable)
		return
	}

	w.WriteHeader(200)
	w.Write([]byte("ok"))
}
