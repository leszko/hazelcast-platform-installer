# Install Hazelcast Jet Enterprise in Air Gapped OpenShift environments

To run Hazelcast Jet Enterprise, you need to load related Docker images into your Docker registry and then start Hazelcast Jet cluster using Helm.

## Step 1: Load Hazelcast Jet Enterprise Docker images into your registry

Execute the following command to load all Hazelcast Jet Enterprise Docker images into your Docker registry.

	docker load -i HAZELCAST_JET_ENTERPRISE_FILENAME
	docker tag HAZELCAST_JET_ENTERPRISE_IMAGE <your-docker-registry>/hazelcast/hazelcast-jet-enterprise:HAZELCAST_JET_ENTERPRISE_VERSION
	docker push <your-docker-registry>/hazelcast/hazelcast-jet-enterprise:HAZELCAST_JET_ENTERPRISE_VERSION

	docker load -i JET_MANAGEMENT_CENTER_FILENAME
	docker tag JET_MANAGEMENT_CENTER_IMAGE <your-docker-registry>/hazelcast/hazelcast-jet-management-center:JET_MANAGEMENT_CENTER_VERSION
	docker push <your-docker-registry>/hazelcast/hazelcast-jet-management-center:JET_MANAGEMENT_CENTER_VERSION

## Step 2: Install Hazelcast Jet Enterprise in OpenShift

To install Hazelcast Jet Enterprise together with Hazelcast Jet Management Center application, you need first to create a secret with the Hazelcast Jet license key.

	oc create secret generic hz-jet-license-key --from-literal=key=JET_LICENSE_KEY

Then, depending on the Helm version you use, run one of the following commands.

    # Helm 2
	helm install --name my-release-jet hazelcast-jet-enterprise-JET_HELM_CHART_VERSION.tgz \
		-f hazelcast-jet-enterprise-values.yaml \
		--set securityContext.runAsUser='',securityContext.fsGroup='',securityContext.runAsGroup='' \
		--set jet.licenseKeySecretName=hz-jet-license-key,managementcenter.licenseKeySecretName=hz-jet-license-key \
		--set image.repository=<your-docker-registry>/hazelcast/hazelcast-jet-enterprise,image.tag=HAZELCAST_JET_ENTERPRISE_VERSION \
		--set managementcenter.image.repository=<your-docker-registry>/hazelcast/hazelcast-jet-management-center,managementcenter.image.tag=JET_MANAGEMENT_CENTER_VERSION
	
	# Helm 3
	helm install my-release-jet hazelcast-jet-enterprise-JET_HELM_CHART_VERSION.tgz \
		-f hazelcast-jet-enterprise-values.yaml \
		--set securityContext.runAsUser='',securityContext.fsGroup='',securityContext.runAsGroup='' \
		--set jet.licenseKeySecretName=hz-jet-license-key,managementcenter.licenseKeySecretName=hz-jet-license-key \
		--set image.repository=<your-docker-registry>/hazelcast/hazelcast-jet-enterprise,image.tag=HAZELCAST_JET_ENTERPRISE_VERSION \
		--set managementcenter.image.repository=<your-docker-registry>/hazelcast/hazelcast-jet-management-center,managementcenter.image.tag=JET_MANAGEMENT_CENTER_VERSION	

You should see that the Hazelcast Jet cluster and Hazelcast Jet Management Center started.

	$ oc get pods
	NAME                                                              READY     STATUS    RESTARTS   AGE
	my-release-jet-hazelcast-jet-enterprise-0                         1/1       Running   0          2m9s
	my-release-jet-hazelcast-jet-enterprise-1                         1/1       Running   0          88s
	my-release-jet-hazelcast-jet-enterprise-management-center-j8hgx   1/1       Running   0          2m9s

Note that you can configure all Hazelcast Jet installation parameters by changing `hazelcast-jet-enterprise-values.yaml` file.
