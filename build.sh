#!/bin/bash

# Check parameters
if [ "$#" -ne 8 ]; then
    echo "Illegal number of parameters"
    echo "./publish_operator.sh <platform-version> <docker-hub/rhel> <hazelcast-enterprise-version> <management-center-version> <hazelcast-enterprise-operator-version> <hazelcast-jet-enterprise-version> <jet-management-center-version> <jet-operator-version>"
    exit 1
fi

PLATFORM_VERSION=$1
REPO=$2
HAZELCAST_VERSION=$3
MANAGEMENT_CENTER_VERSION=$4
OPERATOR_VERSION=$5
HAZELCAST_JET_VERSION=$6
JET_MANAGEMENT_CENTER_VERSION=$7
JET_OPERATOR_VERSION=$8

if [[ "${REPO}" == "rhel" ]]; then
	HAZELCAST_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-4-rhel8:${HAZELCAST_VERSION}"
	MANAGEMENT_CENTER_IMAGE="registry.connect.redhat.com/hazelcast/management-center-4-rhel8:${MANAGEMENT_CENTER_VERSION}"
	OPERATOR_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-enterprise-operator:${OPERATOR_VERSION}"
	HAZELCAST_JET_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-jet-enterprise-4:${HAZELCAST_JET_VERSION}"
	JET_MANAGEMENT_CENTER_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-jet-management-center-4:${JET_MANAGEMENT_CENTER_VERSION}"
	JET_OPERATOR_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-jet-enterprise-operator:${JET_OPERATOR_VERSION}"
elif [[ "${REPO}" == "docker-hub" ]]; then
	HAZELCAST_IMAGE="hazelcast/hazelcast-enterprise:${HAZELCAST_VERSION}"
	MANAGEMENT_CENTER_IMAGE="hazelcast/management-center:${MANAGEMENT_CENTER_VERSION}"
	OPERATOR_IMAGE="hazelcast/hazelcast-enterprise-operator:${OPERATOR_VERSION}"
	HAZELCAST_JET_IMAGE="hazelcast/hazelcast-jet-enterprise:${HAZELCAST_JET_VERSION}"
	JET_MANAGEMENT_CENTER_IMAGE="hazelcast/hazelcast-jet-management-center:${JET_MANAGEMENT_CENTER_VERSION}"
	JET_OPERATOR_IMAGE="hazelcast/hazelcast-jet-enterprise-operator:${JET_OPERATOR_VERSION}"
else
	echo "Wrong repository name, it should be 'rhel' or 'docker-hub', but you specified '${REPO}'"
	exit 1
fi

# Check dependencies
echo "Checking dependencies..."
for dep in docker cut curl sed mvn java; do
    if hash ${dep} 2>/dev/null; then
        echo ${dep} installed...
    else
        echo Please install ${dep}, exiting...
        exit 1
    fi
done

# Download Docker images and prepare files-to-copy.txt
IMAGES="${HAZELCAST_IMAGE} ${MANAGEMENT_CENTER_IMAGE} ${OPERATOR_IMAGE} ${HAZELCAST_JET_IMAGE} ${JET_MANAGEMENT_CENTER_IMAGE} ${JET_OPERATOR_IMAGE}"
for IMAGE in ${IMAGES}; do
	FILENAME="$(echo "${IMAGE}" | sed -e "s/^registry\.connect\.redhat\.com\///" | sed -e "s/^hazelcast\///" | sed -e "s/\:/_/").tar"
	FILE="src/main/resources/${FILENAME}"
	echo "Saving ${IMAGE} in the file ${FILE}"
	if ! docker pull ${IMAGE}; then
		if [[ "${REPO}" == "rhel" ]]; then
			echo "Error while pulling image from Red Hat Registry. Make sure that:"
			echo "- you are logged into Red Hat Container Registry with 'docker login registry.connect.redhat.com'"
			echo "- image tag is correct '${IMAGE}'"
			exit 1
		fi
	fi
	docker save ${IMAGE} -o ${FILE}
	echo "${FILENAME}" >> src/main/resources/files-to-copy.txt
done

# Prepare README Instructions
# TODO
cp INSTALLATION_GUIDE.md src/main/resources/
echo INSTALLATION_GUIDE.md >> src/main/resources/files-to-copy.txt

# Build Java Installation Executable JAR
mvn clean compile assembly:single
