# Install Hazelcast Platform in Air Gapped OpenShift environments

Hazelcast platform can be installed in the air-gapped OpenShift environments. Here are a list of instructions you need to follow.

## Requirements

* Up and running OpenShift cluster and the `oc` command installed and configured
* Docker registry (deployed separately or provided together with OpenShift)
* Docker installed and logged into Docker registry
* [Helm 3](https://helm.sh/docs/intro/install/) tool installed

## Hazelcast Enterprise

To run Hazelcast Enterprise, you need to load related Docker images into your Docker registry and then start Hazelcast cluster using Helm.

### Step 1: Load Hazelcast Enterprise Docker images into your registry

Execute the following command to load all Hazelcast Enterprise Docker images into your Docker registry.

	docker load hazelcast-enterprise-HAZELCAST_ENTERPRISE_VERSION.tar
	docker tag hazelcast/hazelcast-enterprise:HAZELCAST_ENTERPRISE_VERSION <your-docker-registry>/hazelcast/hazelcast-enterprise:HAZELCAST_ENTERPRISE_VERSION
	docker push <your-docker-registry>/hazelcast/hazelcast-enterprise:HAZELCAST_ENTERPRISE_VERSION

	docker load management-center-MANAGEMENT_CENTER_VERSION.tar
	docker tag hazelcast/hazelcast-enterprise:MANAGEMENT_CENTER_VERSION <your-docker-registry>/hazelcast/management-center:MANAGEMENT_CENTER_VERSION
	docker push <your-docker-registry>/hazelcast/management-center:MANAGEMENT_CENTER_VERSION

### Step 2: Install Hazelcast Enterprise in OpenShift

To install Hazelcast Enterprise together with Hazelcast Management Center application, you need first to create a secret with the Hazelcast license key.

		oc create secret generic hz-license-key --from-literal=key=HZ_LICENSE_KEY

Then, run the following command.

	helm install my-release hazelcast-enterprise-HELM_CHART_VERSION.tgz \
		-f hazelcast-enterprise-values.yaml \
		--set securityContext.runAsUser='',securityContext.fsGroup='' \
		--set hazelcast.licenseKeySecretName=hz-license-key \
		--set image.repository=<your-docker-registry>/hazelcast/hazelcast-enterprise,image.tag=HAZELCAST_ENTERPRISE_VERSION \
		--set mancenter.image.repository=<your-docker-registry>/hazelcast/management-center,mancenter.image.tag=MANAGEMENT_CENTER_VERSION

You should see that the Hazelcast cluster and Management Center are started.

	$ oc get pods
	NAME                                          READY     STATUS    RESTARTS   AGE
	my-release-hazelcast-enterprise-0             1/1       Running   0          2m5s
	my-release-hazelcast-enterprise-1             1/1       Running   0          80s
	my-release-hazelcast-enterprise-2             1/1       Running   0          39s
	my-release-hazelcast-enterprise-mancenter-0   1/1       Running   0          2m5s

Note that you can configure all Hazelcast installation parameters by changing the `hazelcast-enterprise-values.yaml` file.

## Hazelcast Jet Enterprise

To run Hazelcast Jet Enterprise, you need to load related Docker images into your Docker registry and then start Hazelcast Jet cluster using Helm.

### Step 1: Load Hazelcast Jet Enterprise Docker images into your registry

Execute the following command to load all Hazelcast Enterprise Docker images into your Docker registry.

	docker load hazelcast-jet-enterprise-HAZELCAST_JET_ENTERPRISE_VERSION.tar
	docker tag hazelcast/hazelcast-jet-enterprise:HAZELCAST_JET_ENTERPRISE_VERSION <your-docker-registry>/hazelcast/hazelcast-jet-enterprise:HAZELCAST_JET_ENTERPRISE_VERSION
	docker push <your-docker-registry>/hazelcast/hazelcast-jet-enterprise:HAZELCAST_JET_ENTERPRISE_VERSION

	docker load management-center-JET_MANAGEMENT_CENTER_VERSION.tar
	docker tag hazelcast/hazelcast-jet-enterprise:JET_MANAGEMENT_CENTER_VERSION <your-docker-registry>/hazelcast/jet-management-center:JET_MANAGEMENT_CENTER_VERSION
	docker push <your-docker-registry>/hazelcast/jet-management-center:JET_MANAGEMENT_CENTER_VERSION

### Step 2: Install Hazelcast Jet Enterprise in OpenShift

To install Hazelcast Jet Enterprise together with Hazelcast Jet Management Center application, you need first to create a secret with the Hazelcast Jet license key.

	oc create secret generic hz-jet-license-key --from-literal=key=JET_LICENSE_KEY

Then, run the following command.

	helm install my-release-jet hazelcast-jet-enterprise-JET_HELM_CHART_VERSION.tgz \
		-f hazelcast-jet-enterprise-values.yaml \
		--set securityContext.runAsUser='',securityContext.fsGroup='' \
		--set jet.licenseKeySecretName=hz-jet-license-key \
		--set image.repository=<your-docker-registry>/hazelcast/hazelcast-jet-enterprise,image.tag=HAZELCAST_JET_ENTERPRISE_VERSION \
		--set managementcenter.image.repository=<your-docker-registry>/hazelcast/hazelcast-jet-management-center,managementcenter.image.tag=JET_MANAGEMENT_CENTER_VERSION

You should see that the Hazelcast cluster and Management Center are started.

	$ oc get pods
	NAME                                                              READY     STATUS    RESTARTS   AGE
	my-release-jet-hazelcast-jet-enterprise-0                         1/1       Running   0          2m9s
	my-release-jet-hazelcast-jet-enterprise-1                         1/1       Running   0          88s
	my-release-jet-hazelcast-jet-enterprise-management-center-j8hgx   1/1       Running   0          2m9s

Note that you can configure all Hazelcast installation parameters by changing the `hazelcast-jet-enterprise-values.yaml` file.
