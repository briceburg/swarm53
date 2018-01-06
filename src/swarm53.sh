#!/usr/bin/env bash
main(){
  local values
  for v in SWARM_NAME SWARM_DOMAIN HOSTED_ZONE_ID; do
    eval "[ -n \"\$$v\" ] || die \"Please provide $v\""
  done

  # add swarm record
  values=()
  for ip in $(aws ec2 describe-instances --filters "Name=tag:SwarmName,Values=$SWARM_NAME" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text); do
    values+=( "{\"Value\":\"$ip\"}" )
  done
  record/update <(record/template "$SWARM_NAME.$SWARM_DOMAIN" $(join ${values[@]}))

  # add swarm managers record
  values=()
  for ip in $(aws ec2 describe-instances --filters "Name=tag:SwarmName,Values=$SWARM_NAME" "Name=tag:Role,Values=swarm-manager" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text); do
    values+=( "{\"Value\":\"$ip\"}" )
  done
  record/update <(record/template "managers.$SWARM_NAME.$SWARM_DOMAIN" $(join ${values[@]}))
}

record/update(){
  aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --output text \
    --change-batch file://$1
}

record/template(){
  cat <<EOR
{
    "Comment": "swarm53 managed record",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$1",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [$2]
            }
        }
    ]
}
EOR
}

join(){ local IFS=","; echo "$*"; }
log(){ echo "swarm53: $*" >&2; }
die(){ log "$*"; exit 1; }

main "$@"
