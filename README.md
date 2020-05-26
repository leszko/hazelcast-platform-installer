# Hazelcast Platform Installer for Air-gapped environments

## Quick Start

Run the following command to create an executable JAR installer from Docker Hub Hazelcast images.

	./build.sh <platform-version> <docker-hub/rhel> <hz-enterprise-version> <hz-management-center-version> <hz-helm-chart-version> <hz-license-key> <jet-enterprise-version> <jet-management-center-version> <jet-helm-chart-version> <jet-license-key>

For example, to create Hazelcast Platform `4.0.1` with the latest Hazelcast images, run the following command.

	./build.sh 4.0.1 docker-hub 4.0.1 4.0.2 3.2.1 <hz-license-key> 4.1 4.1 1.6.0 <jet-license-key>

This command outputs a jar file which is an offline installer.

## Building with RHEL images

If you want to build the installer from Hazelcast images from Red Hat Container catalog, you need to first log into Red Hat Registry.

#### Log into Red Hat Container Catalog

Run the following command and specify your credentials when prompted.

	docker login registry.connect.redhat.com

#### Build RHEL-based installer

The syntax is the same as in the quick start. For the latest Hazelcast Platform RHEL build, run the following command.

	./build.sh 4.0.1 rhel 4.0-1-1 4.0-2 3.2.1 <hz-license-key> 4.1-1 4.1-1 1.6.0 <jet-license-key>

## Using installer

The installer is an executable, you can run it with the following command.

	java -jar hazelcast-platform-installer-<version>.jar

It will extract all files needed for the offline Hazelcast Enterprise (and Hazelcast Jet Enterprise) installation on the OpenShift environment. Please check `INSTALLATION_GUIDE.md` for the detailed instructions.
