#!/bin/bash

image_to_filename() {
  IMAGE=$1
  FILENAME="$(echo "${IMAGE}" | sed -e "s/^registry\.connect\.redhat\.com\///" | sed -e "s/^hazelcast\///" | sed -e "s/\:/-/").tar"
  echo ${FILENAME}
}
# Check parameters
if [ "$#" -ne 13 ]; then
  echo "Illegal number of parameters"
  echo "./build.sh <platform-version> <docker-hub/rhel> <hz-enterprise-version> <hz-management-center-version> <hz-helm-chart-version> <reference-manual-version> <ops-guide-version> <hz-license-key> <docker-hub/rhel> <jet-enterprise-version> <jet-management-center-version> <jet-helm-chart-version> <jet-license-key>"
  echo
  echo "For example, for Hazelcast Platform 4.0.1 build from RHEL, execute the following:"
  echo "./build.sh 4.0.1 rhel 4.0-1-1 4.0-2 3.2.1 4.0.1 4.0.1 <hz-license-key> rhel 4.1-1 4.1-1 1.6.0 <jet-license-key>"
  exit 1
fi

PLATFORM_VERSION=${1}
REPO=${2}
HAZELCAST_VERSION=${3}
MANAGEMENT_CENTER_VERSION=${4}
HELM_CHART_VERSION=${5}
REFERENCE_MANUAL_VERSION=${6}
OPS_GUIDE_VERSION=${7}
HZ_LICENSE_KEY=${8}
JET_REPO=${9}
HAZELCAST_JET_VERSION=${10}
JET_MANAGEMENT_CENTER_VERSION=${11}
JET_HELM_CHART_VERSION=${12}
JET_LICENSE_KEY=${13}

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

if [[ "${JET_REPO}" == "rhel" ]]; then
  HAZELCAST_JET_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-jet-enterprise-4:${HAZELCAST_JET_VERSION}"
  JET_MANAGEMENT_CENTER_IMAGE="registry.connect.redhat.com/hazelcast/hazelcast-jet-management-center-4:${JET_MANAGEMENT_CENTER_VERSION}"
elif [[ "${JET_REPO}" == "docker-hub" ]]; then
  HAZELCAST_JET_IMAGE="hazelcast/hazelcast-jet-enterprise:${HAZELCAST_JET_VERSION}"
  JET_MANAGEMENT_CENTER_IMAGE="hazelcast/hazelcast-jet-management-center:${JET_MANAGEMENT_CENTER_VERSION}"
else
  echo "Wrong repository name, it should be 'rhel' or 'docker-hub', but you specified '${REPO}'"
  exit 1
fi

# Check dependencies
echo "Checking dependencies..."
for dep in docker cut curl sed mvn java tar zip wget gradle; do
  if hash ${dep} 2>/dev/null; then
    echo ${dep} installed...
  else
    echo Please install ${dep}, exiting...
    exit 1
  fi
done

mkdir -p src/main/resources

# Clean up
rm src/main/resources/* -f
rm -r hazelcast-platform* -f

# Copy EULA license
cp eula-licenses.zip src/main/resources/

PLATFORM_DIRECTORY="hazelcast-platform-${PLATFORM_VERSION}"
# Create temp directories with all Hazelcast Platform files
mkdir -p "${PLATFORM_DIRECTORY}/hazelcast-enterprise"
mkdir -p "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise"

# Download Docker images
#IMAGES="${HAZELCAST_IMAGE} ${MANAGEMENT_CENTER_IMAGE} ${HAZELCAST_JET_IMAGE} ${JET_MANAGEMENT_CENTER_IMAGE}"
#for IMAGE in ${IMAGES}; do
#	FILE="${PLATFORM_DIRECTORY}/$(image_to_filename ${IMAGE})"
#	echo "Saving ${IMAGE} in the file ${FILE}"
#	if ! docker pull ${IMAGE}; then
#		if [[ "${REPO}" == "rhel" || "${JET_REPO}" == "rhel" ]]; then
#			echo "Error while pulling image from Red Hat Registry. Make sure that:"
#			echo "- you are logged into Red Hat Container Registry with 'docker login registry.connect.redhat.com'"
#			echo "- image tag is correct '${IMAGE}'"
#			exit 1
#		fi
#	fi
#	docker save ${IMAGE} -o ${FILE}
#done
#mv ${PLATFORM_DIRECTORY}/hazelcast-jet*.tar ${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/
#mv ${PLATFORM_DIRECTORY}/*.tar ${PLATFORM_DIRECTORY}/hazelcast-enterprise/

# Download Reference Manual PDF
#curl -o ${PLATFORM_DIRECTORY}/hazelcast-enterprise/hazelcast-reference-manual.pdf https://docs.hazelcast.org/docs/${PLATFORM_VERSION}/manual/pdf/index.pdf

# Build and include Ops Guide PDF
if [[ "${OPS_GUIDE_VERSION}" == 4* ]]; then
  git clone https://github.com/hazelcast/hazelcast-operations-and-deployment-guide-4.0.git hazelcast-operations-and-deployment-guide
  cd hazelcast-operations-and-deployment-guide
else
  git clone https://github.com/hazelcast/hazelcast-operations-and-deployment-guide.git hazelcast-operations-and-deployment-guide
  cd hazelcast-operations-and-deployment-guide
  git fetch --all
  git checkout v${OPS_GUIDE_VERSION}
fi
gradle build
cd ..
cp hazelcast-operations-and-deployment-guide/build/asciidoc/pdf/index.pdf ${PLATFORM_DIRECTORY}/hazelcast-operations-and-deployment-guide.pdf
rm -r -f hazelcast-operations-and-deployment-guide

exit 1

# Download Helm Charts
helm repo add hazelcast https://hazelcast.github.io/charts/
helm repo update
helm pull hazelcast/hazelcast-enterprise --version ${HELM_CHART_VERSION} -d "${PLATFORM_DIRECTORY}/hazelcast-enterprise/"
helm pull hazelcast/hazelcast-jet-enterprise --version ${JET_HELM_CHART_VERSION} -d "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise"

# Extract values.yaml from Helm Charts
tar zxf "${PLATFORM_DIRECTORY}/hazelcast-enterprise/hazelcast-enterprise-${HELM_CHART_VERSION}.tgz" -C .
cp hazelcast-enterprise/values.yaml "${PLATFORM_DIRECTORY}/hazelcast-enterprise/hazelcast-enterprise-values.yaml"
rm -r hazelcast-enterprise
tar zxf "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/hazelcast-jet-enterprise-${JET_HELM_CHART_VERSION}.tgz" -C .
cp hazelcast-jet-enterprise/values.yaml "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/hazelcast-jet-enterprise-values.yaml"
rm -r hazelcast-jet-enterprise

# Prepare README Instructions
cp INSTALL_GUIDE.md ${PLATFORM_DIRECTORY}/
cp HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md ${PLATFORM_DIRECTORY}/hazelcast-enterprise
cp HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md ${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise

sed -i "s/HAZELCAST_ENTERPRISE_FILENAME/$(image_to_filename ${HAZELCAST_IMAGE})/g" "${PLATFORM_DIRECTORY}/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s~HAZELCAST_ENTERPRISE_IMAGE~${HAZELCAST_IMAGE}~g" "${PLATFORM_DIRECTORY}/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/HAZELCAST_ENTERPRISE_VERSION/${HAZELCAST_VERSION}/g" "${PLATFORM_DIRECTORY}/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/HZ_MANAGEMENT_CENTER_FILENAME/$(image_to_filename ${MANAGEMENT_CENTER_IMAGE})/g" "${PLATFORM_DIRECTORY}/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s~HZ_MANAGEMENT_CENTER_IMAGE~${MANAGEMENT_CENTER_IMAGE}~g" "${PLATFORM_DIRECTORY}/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/HZ_MANAGEMENT_CENTER_VERSION/${MANAGEMENT_CENTER_VERSION}/g" "${PLATFORM_DIRECTORY}/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/HZ_HELM_CHART_VERSION/${HELM_CHART_VERSION}/g" "${PLATFORM_DIRECTORY}/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/HZ_LICENSE_KEY/${HZ_LICENSE_KEY}/g" "${PLATFORM_DIRECTORY}/hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md"

sed -i "s/HAZELCAST_JET_ENTERPRISE_FILENAME/$(image_to_filename ${HAZELCAST_JET_IMAGE})/g" "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s~HAZELCAST_JET_ENTERPRISE_IMAGE~${HAZELCAST_JET_IMAGE}~g" "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/HAZELCAST_JET_ENTERPRISE_VERSION/${HAZELCAST_JET_VERSION}/g" "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/JET_MANAGEMENT_CENTER_FILENAME/$(image_to_filename ${JET_MANAGEMENT_CENTER_IMAGE})/g" "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s~JET_MANAGEMENT_CENTER_IMAGE~${JET_MANAGEMENT_CENTER_IMAGE}~g" "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/JET_MANAGEMENT_CENTER_VERSION/${JET_MANAGEMENT_CENTER_VERSION}/g" "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/JET_HELM_CHART_VERSION/${JET_HELM_CHART_VERSION}/g" "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md"
sed -i "s/JET_LICENSE_KEY/${JET_LICENSE_KEY}/g" "${PLATFORM_DIRECTORY}/hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md"

sed -i "s/PLATFORM_VERSION/${PLATFORM_VERSION}/g" "src/main/java/com/hazelcast/installer/Main.java"

sed -i "s/HAZELCAST_ENTERPRISE_FILENAME/$(image_to_filename ${HAZELCAST_IMAGE})/g" "${PLATFORM_DIRECTORY}/INSTALL_GUIDE.md"
sed -i "s/HZ_MANAGEMENT_CENTER_FILENAME/$(image_to_filename ${MANAGEMENT_CENTER_IMAGE})/g" "${PLATFORM_DIRECTORY}/INSTALL_GUIDE.md"
sed -i "s/HZ_HELM_CHART_VERSION/${HELM_CHART_VERSION}/g" "${PLATFORM_DIRECTORY}/INSTALL_GUIDE.md"
sed -i "s/HAZELCAST_JET_ENTERPRISE_FILENAME/$(image_to_filename ${HAZELCAST_JET_IMAGE})/g" "${PLATFORM_DIRECTORY}/INSTALL_GUIDE.md"
sed -i "s/JET_MANAGEMENT_CENTER_FILENAME/$(image_to_filename ${JET_MANAGEMENT_CENTER_IMAGE})/g" "${PLATFORM_DIRECTORY}/INSTALL_GUIDE.md"
sed -i "s/JET_HELM_CHART_VERSION/${JET_HELM_CHART_VERSION}/g" "${PLATFORM_DIRECTORY}/INSTALL_GUIDE.md"

# Zip all files to copy
zip -r "src/main/resources/hazelcast-platform.zip" ${PLATFORM_DIRECTORY}

# Build Java Installation Executable JAR
mvn install:install-file -Dfile=LAPApp.jar -DgroupId=com.ibm -DartifactId=lapapp -Dversion=1.0 -Dpackaging=jar
mvn clean compile assembly:single

# Clean up
rm src/main/resources/*
rm -r ${PLATFORM_DIRECTORY} -f
mv target/hazelcast-platform-installer-1.0-SNAPSHOT-jar-with-dependencies.jar ./hazelcast-platform-installer-${PLATFORM_VERSION}.jar
rm -r target

# Create Hazelcast Platform Package (Platform JAR + OpenJDK distribution)
wget https://download.java.net/java/GA/jdk14.0.1/664493ef4a6946b186ff29eb326336a2/7/GPL/openjdk-14.0.1_linux-x64_bin.tar.gz
tar xf openjdk-14.0.1_linux-x64_bin.tar.gz
PLATFORM_PACKAGE_DIRECTORY="hazelcast-platform-package-${PLATFORM_VERSION}"
mkdir ${PLATFORM_PACKAGE_DIRECTORY}
mv jdk-14.0.1 ${PLATFORM_PACKAGE_DIRECTORY}/jdk
mv hazelcast-platform-installer-${PLATFORM_VERSION}.jar ${PLATFORM_PACKAGE_DIRECTORY}
cp install.sh ${PLATFORM_PACKAGE_DIRECTORY}
sed -i "s/PLATFORM_VERSION/${PLATFORM_VERSION}/g" "${PLATFORM_PACKAGE_DIRECTORY}/install.sh"
zip -r ${PLATFORM_PACKAGE_DIRECTORY}.zip ${PLATFORM_PACKAGE_DIRECTORY}

# Clean up Hazelcast Platform Package
rm -r -f ${PLATFORM_PACKAGE_DIRECTORY}
rm openjdk-14.0.1_linux-x64_bin.tar.gz
