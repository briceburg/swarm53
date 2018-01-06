#!/usr/bin/env bash
main(){
  # initial update (on first run)
  log "updating DNS records from current state..."
  swarm53 || exit 1

  # monitor for topology chnges and run again
  log "monitoring for topology changes..."
  docker events -f 'scope=swarm' -f 'type=node' -f 'event=create' -f 'event=remove' | while read event
  do
    log "detected topology change: $event"
    log "sleeping 30s..."
    sleep 30
    swarm53 || exit 1
  done
}
log(){ echo "swarm53: $*" >&2; }

main "$@"
