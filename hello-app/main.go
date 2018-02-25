/**
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// [START all]
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

var version string
var started time.Time

func main() {
	fmt.Println(version)
	started = time.Now()

	port := "8080"
	if fromEnv := os.Getenv("PORT"); fromEnv != "" {
		port = fromEnv
	}

	server := http.NewServeMux()
	server.HandleFunc("/", hello)
	server.HandleFunc("/healthz", healthz)
	server.HandleFunc("/readiness", readiness)
	log.Printf("Server listening on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, server))
}

func hello(w http.ResponseWriter, r *http.Request) {
	log.Printf("Serving request: %s", r.URL.Path)
	host, _ := os.Hostname()
	fmt.Fprintf(w, "Hello, world!\n")
	fmt.Fprintf(w, "Version: 1.0.0\n")
	fmt.Fprintf(w, "Hostname: %s\n", host)
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

// [END all]
