# Install Hazelcast Platform in Air Gapped OpenShift environments

Hazelcast platform can be installed in the air-gapped OpenShift environments. Here are a list of instructions you need to follow.

## Requirements

* Up and running OpenShift cluster and the `oc` command installed and configured
* Docker registry (deployed separately or provided together with OpenShift)
* Docker installed and logged into Docker registry
* [Helm 3](https://helm.sh/docs/intro/install/) tool installed

## Hazelcast Enterprise

To run Hazelcast Enterprise, you need to load the related Docker images into your Docker registry and then start Hazelcast cluster using Helm.

### Step 1: Load Hazelcast Enterprise Docker images into your registry

Execute the following command to load all Hazelcast Enterprise Docker images into your Docker registry.

		docker load hazelcast-enterprise.tar
		docker tag hazelcast/hazelcast-enterprise:4.0.1 <your-docker-registry>/hazelcast/hazelcast-enterprise:4.0.1
		docker push <your-docker-registry>/hazelcast/hazelcast-enterprise:4.0.1

		docker load management-center.tar
		docker tag hazelcast/hazelcast-enterprise:4.0.1 <your-docker-registry>/hazelcast/management-center:4.0.1
		docker push <your-docker-registry>/hazelcast/management-center:4.0.1

### Step 2: Install Hazelcast Enterprise in OpenShift

TODO

## Hazelcast Jet Enterprise

TODO

### Step 1: Load Hazelcast Jet Enterprise Docker images into your registry

TODO

### Step 2: Install Hazelcast Jet Enterprise in OpenShift

TODO

