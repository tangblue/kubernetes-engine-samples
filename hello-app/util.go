package main

import (
	"fmt"
	"net/http"
	"time"
)

var version string
var started time.Time

func init() {
	fmt.Println("Version:", version)
	started = time.Now()
}

func healthz(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(200)
	w.Write([]byte("ok"))
}

func readiness(w http.ResponseWriter, r *http.Request) {
	errMsg := ""
	duration := time.Now().Sub(started)
	if duration.Seconds() < 10 {
		errMsg += "Database not ok.\n"
		http.Error(w, errMsg, http.StatusServiceUnavailable)
	} else {
		w.WriteHeader(200)
		w.Write([]byte("ok"))
	}
}
