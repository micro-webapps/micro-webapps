# Creating simple micro-webapps application - Simple Owncloud example

This document describes how to create new micro-webapps application from the existing Docker image and ship it using Nulecule. We will take Owncloud as an example of simple web application, but every step described in this document is quite general and can be applied to any web application.

Before continuing with reading, you should know the [basic micro-webapps architecture](../README.md).

## Preparing or finding Docker image with the web application

At first, we have to find out the right Docker image which will be used in the micro-webapps application. For the Owncloud, we can use [jchaney/owncloud](https://registry.hub.docker.com/jchaney/owncloud/) Docker Image.

## Creating the Kubernetes or Openshift pod definition for the Owncloud

Now we have to describe the [pod](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/pods.md) file for the Kubernetes or Openshift. This document does not describe the pod syntax, please refer to official [Kubernetes documentation](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/pods.md) instead.

The resulting pod could look like this:

    apiVersion: v1
    kind: Pod
    metadata:
      name: webapp-owncloud
      labels:
        app: webapp-owncloud
    spec:
      containers:
        - name: webapp-owncloud
          image: jchaney/owncloud
          ports:
            - containerPort: 80
          volumeMounts:
            - name: data-persistent-storage
              mountPath: /var/www/owncloud/data
            - name: config-persistent-storage
              mountPath: /var/www/owncloud/config
      volumes:
        - name: data-persistent-storage
          source:
            emptyDir: {}
        - name: config-persistent-storage
          source:
            emptyDir: {}

There is nothing special in the pod file. We will store the pod file as `./artifacts/kubernetes/owncloud-pod.yaml`.

## Creating the Kubernetes or Openshift service for Owncloud

Again, this document does not discuss what's the Kubernetes or Openshift service, please check the [official documentation]([Kubernetes documentation](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/pods.md). It focuses more on the micro-webapps related parts of the service definition.

The service definition for Owncloud using the micro-webapps could look like this:

    {
        "apiVersion": "v1",
        "kind": "Service",
        "metadata": {
            "name": "webapp-owncloud",
            "annotations": {
                "webconf-spec": "{\"virtualhost\": \"$mwa_vhost\",\"proxy\": { \"url\": \"http://webapp/owncloud\", \"alias\": \"$mwa_alias\"}}"
            }
        },
        "spec": {
            "selector": {
                "app": "webapp-owncloud"
            },
            "ports": [
                {
                    "name": "http-port",
                    "protocol": "TCP",
                    "port": 80,
                    "targetPort": 80
                }
            ]
        }
    }

The sevice is quite normal. What makes it little bit special is its `annotations` part. The `webconf-spec` attribute contains the webserver configuration in the [webconf-spec format](https://github.com/micro-webapps/webconf-spec). If we unescape that part, it looks like this:

    {
        "virtualhost": "$mwa_vhost",
        "proxy": {
            "url": "http://webapp/owncloud",
            "alias": "$mwa_alias"
        }
    }

When the Owncloud Nulecule is deployed, this configuration is stored in the Kubernetes or Openshift API-server and micro-webapps frontend will fetch it and change its setting to make the Owncloud web application accessible. The `$mwa_vhost` and `$mwa_alias` variables are replaced with proper values when the Nulecule we are creating is deployed by the admin.

In our case, the micro-webapps frontend will proxy the incoming requests from `http://$mwa_vhost$mwa_alias` to the internal backend using the HTTP protocol. It knows the IP address and port from the Kubernetes or Openshift, so we do not have to provide it and just use dummy `webapp` hostname. We use `/owncloud` path in the proxy URL, so the frontend also knows that the Owncloud is accessible as "/owncloud" on the backend server.

We will store the service file as `./artifacts/kubernetes/owncloud-service.json`.

## Creating the Nulecule file

Now it's time to create the Nulecule with the pod and service files. Again, there is nothing special in the Nulecule file. We just mark the `$mwa_host` and `$mwa_alias` variables as parameters for the Nulecule:

    ---
    specversion: 0.0.2
    id: webapp-wordpress-atomicapp
    metadata:
      name: Wordpress
      appversion: 1.0.0
      description: >
        This is a nulecule that will get you the container with Wordpress which
        is able to run with httpd-frontend.
    graph:
      - name: aggregated-mysql-atomicapp
        source: docker://projectatomic/mysql-centos7-atomicapp
      - name: webapp-wordpress
        params:
        - name: mwa_vhost
          description: >
            Virtual-host where Owncloud should be served.
          default: localhost
        - name: mwa_alias
          description: >
            Alias which should be used to serve the Owncloud.
          default: /owncloud
        artifacts:
          kubernetes:
            - file://artifacts/kubernetes/wordpress-pod.yaml
            - file://artifacts/kubernetes/wordpress-service.json
          openshift:
            - inherit:
              - kubernetes

## Creating the Dockerfile

Because the Nulecule is based on Docker images, we have to create Dockerfile to be able to build Docker image for our Owncloud atomicapp. This is well described in the [Nulecule documentation](https://github.com/projectatomic/nulecule/blob/master/docs/getting-started.md). The Dockerfile in our case will look like this:

    FROM projectatomic/atomicapp:latest

    MAINTAINER Jan Kaluza <jkaluza@redhat.com>

    LABEL io.projectatomic.nulecule.specversion 0.0.2

    LABEL Build docker build --rm --tag testing/webapp-wordpress-atomicapp .

    ADD Nulecule /application-entity/
    ADD artifacts/ /application-entity/artifacts/

You should be able to build the Docker image now using the Docker registry or local build.

## Deploying the Owncloud micro-webapp

Deployment is described in another article:

  * [Deploying micro-webapps application - Kubernetes](deploy-owncloud-webapp-kubernetes.md)
  * [Deploying micro-webapps application - Openshift](deploy-wordpress-webapp.md)

