#!/bin/bash
HZ_LICENSE_KEY=${1}
JET_LICENSE_KEY=${2}
./build.sh 3.0 rhel 3.12.7 3.12.9 2.9.1 3.12.7 3.12.2 ${HZ_LICENSE_KEY} docker-hub 3.2.2 3.2.2 1.2.0 ${JET_LICENSE_KEY}