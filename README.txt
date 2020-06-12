# Hazelcast Platform Installer for OpenShift Environments

This package contains the Hazelcast Platform (Hazelcast IMDG Enterprise and Hazelcast Jet Enterprise) installer for air-gapped environments. It includes the whole OpenJdk, so no pre-installed Java toolkit is needed.

## Requirements

* Up and running OpenShift cluster and the `oc` command installed and configured
* Docker registry (deployed separately or provided together with OpenShift)
* Docker installed and logged into Docker registry
* [Helm 3](https://helm.sh/docs/intro/install/) tool installed

## Installation steps

* Execute `./install.sh`
* Read the Eula license and accept it by typing `1`
* Hazelcast Platform files are extracted and you can find OpenShift installation steps in the file `hazelcast-platform-<version>/INSTALL_GUIDE.md`

## Documentation

* Hazelcast IMDG Enterprise documentation (also included in the package): https://hazelcast.org/imdg/docs/
* Hazelcast Jet Enterprise documentation: https://jet-start.sh/

