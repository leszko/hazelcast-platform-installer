# Install Hazelcast Platform in Air Gapped OpenShift environments

Hazelcast platform can be installed in the air-gapped OpenShift environments.

## Package structure

This package contains all files needed to install Hazelcast Enterprise and Hazelcast Jet Enterprise:
* Installation instructions (`*.md`)
* Docker images (`*.tar`)
* Helm charts (`*.tgz`)
* Helm chart configurations (`*.yaml`)

The package has the following structure.

    +-- INSTALL_GUIDE.md
    +-- hazelcast-enterprise
    |   +-- HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md
    |   +-- HAZELCAST_ENTERPRISE_FILENAME
    |   +-- HZ_MANAGEMENT_CENTER_FILENAME
    |   +-- hazelcast-enterprise-HZ_HELM_CHART_VERSION.tgz
    |   +-- hazelcast-enterprise-values.yaml
    +-- hazelcast-jet-enterprise
    |   +-- HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md
    |   +-- HAZELCAST_JET_ENTERPRISE_FILENAME
    |   +-- JET_MANAGEMENT_CENTER_FILENAME
    |   +-- hazelcast-jet-enterprise-JET_HELM_CHART_VERSION.tgz
    |   +-- hazelcast-enterprise-values.yaml

## Requirements

* Up and running OpenShift cluster and the `oc` command installed and configured
* Docker registry (deployed separately or provided together with OpenShift)
* Docker installed and logged into Docker registry
* [Helm 3](https://helm.sh/docs/intro/install/) tool installed

## Installation steps

You can find an installation guide using the following links:
* [Hazelcast Enterprise Installation Guide](hazelcast-enterprise/HAZELCAST_ENTERPRISE_INSTALL_GUIDE.md)
* [Hazelcast Jet Enterprise Installation Guide](hazelcast-jet-enterprise/HAZELCAST_JET_ENTERPRISE_INSTALL_GUIDE.md)
