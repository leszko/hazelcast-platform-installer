# Install Hazelcast IMDG Enterprise in Air Gapped OpenShift environments

To run Hazelcast IMDG Enterprise, you need to load related Docker images into your Docker registry and then start Hazelcast cluster using Helm.

## Step 1: Load Hazelcast IMDG Enterprise Docker images into your registry

Execute the following command to load all Hazelcast IMDG Enterprise Docker images into your Docker registry.

	docker load -i HAZELCAST_ENTERPRISE_FILENAME
	docker tag HAZELCAST_ENTERPRISE_IMAGE <your-docker-registry>/hazelcast/hazelcast-enterprise:HAZELCAST_ENTERPRISE_VERSION
	docker push <your-docker-registry>/hazelcast/hazelcast-enterprise:HAZELCAST_ENTERPRISE_VERSION

	docker load -i HZ_MANAGEMENT_CENTER_FILENAME
	docker tag HZ_MANAGEMENT_CENTER_IMAGE <your-docker-registry>/hazelcast/management-center:HZ_MANAGEMENT_CENTER_VERSION
	docker push <your-docker-registry>/hazelcast/management-center:HZ_MANAGEMENT_CENTER_VERSION

## Step 2: Install Hazelcast IMDG Enterprise in OpenShift

To install Hazelcast IMDG Enterprise together with Hazelcast Management Center application, you need first to create a secret with the Hazelcast license key.

	oc create secret generic hz-license-key --from-literal=key=HZ_LICENSE_KEY

Then, run the following command.

	helm install my-release hazelcast-enterprise-HZ_HELM_CHART_VERSION.tgz \
		-f hazelcast-enterprise-values.yaml \
		--set securityContext.runAsUser='',securityContext.fsGroup='' \
		--set hazelcast.licenseKeySecretName=hz-license-key \
		--set image.repository=<your-docker-registry>/hazelcast/hazelcast-enterprise,image.tag=HAZELCAST_ENTERPRISE_VERSION \
		--set mancenter.image.repository=<your-docker-registry>/hazelcast/management-center,mancenter.image.tag=HZ_MANAGEMENT_CENTER_VERSION

You should see that the Hazelcast cluster and Management Center started.

	$ oc get pods
	NAME                                          READY     STATUS    RESTARTS   AGE
	my-release-hazelcast-enterprise-0             1/1       Running   0          2m5s
	my-release-hazelcast-enterprise-1             1/1       Running   0          80s
	my-release-hazelcast-enterprise-2             1/1       Running   0          39s
	my-release-hazelcast-enterprise-mancenter-0   1/1       Running   0          2m5s

Note that you can configure all Hazelcast installation parameters by changing the `hazelcast-enterprise-values.yaml` file.

# Further Documentation

You can check the attached documentation files for more information on how to configure Hazelcast:
* [Hazelcast Reference Manual](hazelcast-reference-manual.pdf)
* [Hazelcast Operations and Deployment Guide](hazelcast-operations-and-deployment-guide.pdf)