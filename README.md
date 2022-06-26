# suspend-resume-gcp-compute

Cloud function to resume / suspend instances in GCP

# author

Tomer Tcherniak

# info

```
Only GCP instances which have the below values can be suspended :

Machine type,Netwroks Tags,Service account and instance lables

```
# cloud function environment variables

```
PROJECT_ID = project to run instance discovery

SERVICE_ACCOUNT = service account to attach to the instance

TAGITEMS = network tag to attach to the instance
```

# prerequisite
```
In this example the machines which will be suspend / resume use types :
"n2-standard-16" , "n2-standard-8"

In case diffrent types have to be stopped , please change python instance search types

Labels with with resume or suspend values have to be set with utc time
```
# terraform version

Terraform v1.1.4

# run exmaple
```
In order to run it needed the below values to be set in the instance labels:

For example -
resume : true
resume-time-utc : 5
suspend : true
suspend-time-utc : 4
suspend-week-day-ignore: saturday,friday

This example will suspend in 4AM UTC and resume 5AM UTC and ignoring saturday,friday
```

# utctime

to understand the current utc time https://www.utctime.net/

# cloud scheduler

The suspend / resume run every hour and call the cloud function

suspend runs on 0 * * * *

resume runs on 15 * * * *

The cloud function check if the utc time label match the current time and then it will trigerr action accordingly
