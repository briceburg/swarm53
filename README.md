# swarm53

registers swarm nodes with a route53 hostedzone.

## usage

Example Zone: `acme.tld`

```
docker run --rm \
  -e SWARM_NAME=alpha \
  -e AWS_DEFAULT_REGION=us-east-2 \
  -e HOSTED_ZONE_ID=Z3463YG518IZIW \
  -e SWARM_DOMAIN=swarms.acme.tld \
  swarm53
```

#### effect

Record | Name | Value(s) | Description
--- | --- | --- | ---
A | `alpha.swarms.acme.tld.` | 18.12.6.0.1 18.12.6.0.2 18.12.6.0.3 18.12.6.0.4 18.12.6.0.5 | Public IP of all nodes in acme swarm
A | `managers.alpha.swarms.acme.tld.` | 18.12.6.0.1 18.12.6.0.2 | Public IP of all managers


### monitoring for topology changes

The swarm53 container can be invoked in *monitor* mode. When the swarm topology
changes, swarm53 will update DNS records after a brief 30 second delay to allow
instance termination.

* Set the _entrypoint_ to `swarm53-monitor` enable monitor mode.
* Bind the **required** host's docker socket.
* Run on a manager node only.

```
docker run --rm .... \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --entrypoint swarm53-monitor \
  swarm53
```

## requirements

#### AWS tags on all swarm EC2 instances

Tag | Description | Example
--- | --- | ---
**SwarmName** | unique name of swarm | 'alpha'
**Role** | node role | 'swarm-manager' or 'swarm-worker'

#### IAM instance role

Policy must grant `ec2:DescribeInstances` and `route53:ChangeResourceRecordSets` prermissions.

Example policy JSON granting access explicitly to the hosted zone `Z3463YG518IZIW`:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets",
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/Z3463YG518IZIW",
            ]
        },
        {
            "Effect": "Allow",
            "Action": "ec2:DescribeInstances",
            "Resource": "*"
        }
    ]
}
```
## TODO
* use r53 healthchecks and multivalue answers
