#!/bin/bash

image_to_filename() {
    IMAGE=$1
    FILENAME="$(echo "${IMAGE}" | sed -e "s/^registry\.connect\.redhat\.com\///" | sed -e "s/^hazelcast\///" | sed -e "s/\:/-/").tar"
    echo ${FILENAME}
}
# Check parameters
if [ "$#" -ne 10 ]; then
    echo "Illegal number of parameters"
    echo "./build.sh <platform-version> <docker-hub/rhel> <hz-enterprise-version> <hz-management-center-version> <hz-helm-chart-version> <hz-license-key> <jet-enterprise-version> <jet-management-center-version> <jet-helm-chart-version> <jet-license-key>"
    echo
    echo "For example, for Hazelcast Platform 4.0.1 build from RHEL, execute the following:"
    echo "./build.sh 4.0.1 rhel 4.0-1-1 4.0-2 3.2.1 <hz-license-key> 4.1-1 4.1-1 1.6.0 <jet-license-key>"
    exit 1
fi

PLATFORM_VERSION=${1}
REPO=${2}
HAZELCAST_VERSION=${3}
MANAGEMENT_CENTER_VERSION=${4}
HELM_CHART_VERSION=${5}
HZ_LICENSE_KEY=${6}
HAZELCAST_JET_VERSION=${7}
JET_MANAGEMENT_CENTER_VERSION=${8}
JET_HELM_CHART_VERSION=${9}
JET_LICENSE_KEY=${10}

if [[ "${REPO}" == "rhel" ]]; then
	HAZELCAST_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-4-rhel8:${HAZELCAST_VERSION}"
	MANAGEMENT_CENTER_IMAGE="registry.connect.redhat.com/hazelcast/management-center-4-rhel8:${MANAGEMENT_CENTER_VERSION}"
	HAZELCAST_JET_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-jet-enterprise-4:${HAZELCAST_JET_VERSION}"
	JET_MANAGEMENT_CENTER_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-jet-management-center-4:${JET_MANAGEMENT_CENTER_VERSION}"
elif [[ "${REPO}" == "docker-hub" ]]; then
	HAZELCAST_IMAGE="hazelcast/hazelcast-enterprise:${HAZELCAST_VERSION}"
	MANAGEMENT_CENTER_IMAGE="hazelcast/management-center:${MANAGEMENT_CENTER_VERSION}"
	HAZELCAST_JET_IMAGE="hazelcast/hazelcast-jet-enterprise:${HAZELCAST_JET_VERSION}"
	JET_MANAGEMENT_CENTER_IMAGE="hazelcast/hazelcast-jet-management-center:${JET_MANAGEMENT_CENTER_VERSION}"
else
	echo "Wrong repository name, it should be 'rhel' or 'docker-hub', but you specified '${REPO}'"
	exit 1
fi

# Check dependencies
echo "Checking dependencies..."
for dep in docker cut curl sed mvn java tar zip; do
    if hash ${dep} 2>/dev/null; then
        echo ${dep} installed...
    else
        echo Please install ${dep}, exiting...
        exit 1
    fi
done

# Clean up
rm src/main/resources/* -f
rm -r hazelcast-platform -f

# Copy EULA license
cp eula-licenses.zip src/main/resources/

# Create temp directories with all Hazelcast Platform files
mkdir -p hazelcast-platform/hazelcast-enterprise
mkdir -p hazelcast-platform/hazelcast-jet-enterprise

# Download Docker images
IMAGES="${HAZELCAST_IMAGE} ${MANAGEMENT_CENTER_IMAGE} ${HAZELCAST_JET_IMAGE} ${JET_MANAGEMENT_CENTER_IMAGE}"
for IMAGE in ${IMAGES}; do
	FILE="hazelcast-platform/$(image_to_filename ${IMAGE})"
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
done
mv hazelcast-platform/hazelcast-jet*.tar hazelcast-platform/hazelcast-jet-enterprise/
mv hazelcast-platform/*.tar hazelcast-platform/hazelcast-enterprise/

# Download Helm Charts
helm repo add hazelcast https://hazelcast.github.io/charts/
helm repo update
helm pull hazelcast/hazelcast-enterprise --version ${HELM_CHART_VERSION} -d hazelcast-platform/hazelcast-enterprise/
helm pull hazelcast/hazelcast-jet-enterprise --version ${JET_HELM_CHART_VERSION} -d hazelcast-platform/hazelcast-jet-enterprise

# Extract values.yaml from Helm Charts
tar zxf hazelcast-platform/hazelcast-enterprise/hazelcast-enterprise-${HELM_CHART_VERSION}.tgz -C .
cp hazelcast-enterprise/values.yaml hazelcast-platform/hazelcast-enterprise/hazelcast-enterprise-values.yaml
rm -r hazelcast-enterprise
tar zxf hazelcast-platform/hazelcast-jet-enterprise/hazelcast-jet-enterprise-${JET_HELM_CHART_VERSION}.tgz -C .
cp hazelcast-jet-enterprise/values.yaml hazelcast-platform/hazelcast-jet-enterprise/hazelcast-jet-enterprise-values.yaml
rm -r hazelcast-jet-enterprise

# Prepare README Instructions
cp INSTALL_GUIDE.md hazelcast-platform/
cp HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md hazelcast-platform/hazelcast-enterprise
cp HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md hazelcast-platform/hazelcast-jet-enterprise

sed -i "s/HAZELCAST_ENTERPRISE_FILENAME/$(image_to_filename ${HAZELCAST_IMAGE})/g" hazelcast-platform/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s~HAZELCAST_ENTERPRISE_IMAGE~${HAZELCAST_IMAGE}~g" hazelcast-platform/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/HAZELCAST_ENTERPRISE_VERSION/${HAZELCAST_VERSION}/g" hazelcast-platform/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/HZ_MANAGEMENT_CENTER_FILENAME/$(image_to_filename ${MANAGEMENT_CENTER_IMAGE})/g" hazelcast-platform/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s~HZ_MANAGEMENT_CENTER_IMAGE~${MANAGEMENT_CENTER_IMAGE}~g" hazelcast-platform/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/HZ_MANAGEMENT_CENTER_VERSION/${MANAGEMENT_CENTER_VERSION}/g" hazelcast-platform/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/HZ_HELM_CHART_VERSION/${HELM_CHART_VERSION}/g" hazelcast-platform/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/HZ_LICENSE_KEY/${HZ_LICENSE_KEY}/g" hazelcast-platform/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md

sed -i "s/HAZELCAST_JET_ENTERPRISE_FILENAME/$(image_to_filename ${HAZELCAST_JET_IMAGE})/g" hazelcast-platform/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s~HAZELCAST_JET_ENTERPRISE_IMAGE~${HAZELCAST_JET_IMAGE}~g" hazelcast-platform/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/HAZELCAST_JET_ENTERPRISE_VERSION/${HAZELCAST_JET_VERSION}/g" hazelcast-platform/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/JET_MANAGEMENT_CENTER_FILENAME/$(image_to_filename ${JET_MANAGEMENT_CENTER_IMAGE})/g" hazelcast-platform/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s~JET_MANAGEMENT_CENTER_IMAGE~${JET_MANAGEMENT_CENTER_IMAGE}~g" hazelcast-platform/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/JET_MANAGEMENT_CENTER_VERSION/${JET_MANAGEMENT_CENTER_VERSION}/g" hazelcast-platform/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/JET_HELM_CHART_VERSION/${JET_HELM_CHART_VERSION}/g" hazelcast-platform/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md
sed -i "s/JET_LICENSE_KEY/${JET_LICENSE_KEY}/g" hazelcast-platform/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md

# Zip all files to copy
cd hazelcast-platform
zip -r ../src/main/resources/hazelcast-platform.zip *
cd ..

# Build Java Installation Executable JAR
mvn install:install-file -Dfile=LAPApp.jar -DgroupId=com.ibm -DartifactId=lapapp -Dversion=1.0 -Dpackaging=jar
mvn clean compile assembly:single

# Clean up
rm src/main/resources/*
rm -r hazelcast-platform -f
mv target/hazelcast-platform-installer-1.0-SNAPSHOT-jar-with-dependencies.jar ./hazelcast-platform-installer-${PLATFORM_VERSION}.jar
rm -r target
