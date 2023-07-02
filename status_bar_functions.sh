#!/bin/sh
start_status_bar() {
  source "/home/octoshrimpy/projects/premux/bar.sh"
}

stop_status_bar() {
  killall -SIGUSR1 bash
}
