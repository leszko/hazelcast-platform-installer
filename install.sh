#!/bin/bash
DIR=$(dirname $0)
JRE_PATH="${DIR}/jdk"
${JRE_PATH}/bin/java -jar "${DIR}/hazelcast-platform-installer-PLATFORM_VERSION.jar"