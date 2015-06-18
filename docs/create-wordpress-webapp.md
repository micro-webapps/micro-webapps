# Creating the micro-webapps application - Wordpress example

This document describes how you can create new Nulecule micro-webapps application from the existing Docker image. After reading this document, you should be able to take any Docker image with web-application and make micro-webapps ready Nulecule. We will take Wordpress as an example of complex web application, but every step described in this document is quite general and can be applied to any web application.

## Preparing or finding Docker image with the web application

At first, we have to find out the right Docker image which will be used in the micro-webapps application. For the Wordpress, it's quite easy, because there is [official Wordpress Docker image](https://registry.hub.docker.com/_/wordpress/) ready.

The ideal web application image should serve the web application in the server's root directory, so if you access http://server_ip/, you should see the web application running. This is the case for official wordpress image.

The Wordpress Docker image has one dependency - MySQL. We therefore have to create or find the MySQL Nulecule we could use with the Wordpress. Fortunately, there is [projectatomic/mysql-centos7-atomicapp](https://registry.hub.docker.com/u/projectatomic/mysql-centos7-atomicapp/) Nulecule ready for us to use.

## Creating the Kubernetes or Openshift pod definition for the Wordpress

Now we have to describe the [pod](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/pods.md) file for the Kubernetes and Openshift. In this document, I won't describe the pod syntax, please refer to official [Kubernetes documentation](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/pods.md) instead.

The resulting pod could look like this:

    apiVersion: v1beta1
    id: webapp-wordpress
    desiredState:
      manifest:
        version: v1beta1
        id: webapp-wordpress
        containers:
        - name: webapp-wordpress
          image: wordpress
          ports:
            - containerPort: 80
          env:
            - name: WORDPRESS_DB_PASSWORD
              value: $db_user
            - name: WORDPRESS_DB_USER
              value: $db_password
    labels:
      name: webapp-wordpress
    kind: Pod

There is nothing special in the pod file. We will store the pod file as `./artifacts/kubernetes/wordpress-pod.yaml`.

## Creating the Kubernetes or Openshift service for Wordpress

Again, I won't discuss what's the Kubernetes or Openshift service, please check the [official documentation]([Kubernetes documentation](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/pods.md). I will focus more on the micro-webapps related parts of the service definition.

The service for Wordpress using the micro-webapps could look like this:

    {
        "kind": "Service",
        "apiVersion": "v1beta3",
        "metadata": {
            "name": "webapp-wordpress",
            "annotations": {
                "mwa_webconfig": "{\"virtualhost\": \"$mwa_vhost\",\"proxy_protocol\": \"http://\",\"proxy_alias\": \"$mwa_alias\",\"proxy_backend_alias\": \"/\"}"
            }
        },
        "spec": {
            "selector": {
                "name": "webapp-wordpress"
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

The sevice is quite normal. What makes it little bit special is its `annotations` part. The `mwa_webconfig` field contains the webserver configuration in the [webconf-spec format](https://github.com/micro-webapps/webconf-spec). If we unescape that part, it looks like this:

    {
        "virtualhost": "$mwa_vhost",
        "proxy_protocol": "http://",
        "proxy_alias": "$mwa_alias",
        "proxy_backend_alias": "/"
    }

When the Wordpress is created, this configuration is stored in the Kubernetes or Openshift API-server and micro-webapps frontend will download it and changes its setting to make the Wordpress web application accessible.

In our case, it will proxy the incoming requests from `http://$mwa_host$mwa_alias` to the internal IP address and port of the Wordpress container using the `http://` protocol. It also knows that on that backend server, the Wordpress is accessible in the root (`/`) directory.

The `$mwa_host` and `$mwa_alias` variables are replaced with proper values when the Nulecule we are creating is deployed by the admin.

 We will store the service file as `./artifacts/kubernetes/wordpress-service.json`.

## Creating the Nulecule file

Now it's time to create the Nulecule with the pod and service files. Again, there is nothing special in the Nulecule file. We just mark the `$mwa_host` and `$mwa_alias` variables as parameters for the Nulecule:

    ---
    specversion: 0.0.2
    id: webapp-wordpress-atomicapp
    metadata:
      name: Wordpress
      appversion: 1.1.0
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
          default: /blog
        - name: db_user
          description: User used to access MySQL database.
          default: root
        - name: db_password
          description: Password used to access MySQL database.
          default: yourpassword
        artifacts:
          kubernetes:
            - file://artifacts/kubernetes/wordpress-pod.yaml
            - file://artifacts/kubernetes/wordpress-service.json
          openshift:
            - inherit:
              - kubernetes

## Creating the Dockerfile

Because the Nulecule is Docker image, we have to create Dockerfile to be able to build it. This is well described in the [Nulecule documentation](https://github.com/projectatomic/nulecule/blob/master/docs/getting-started.md). The Dockerfile in our case will look like this:

    FROM projectatomic/atomicapp:latest

    MAINTAINER Jan Kaluza <jkaluza@redhat.com>

    LABEL io.projectatomic.nulecule.specversion 0.0.2

    LABEL Build docker build --rm --tag testing/webapp-wordpress-atomicapp .

    ADD Nulecule /application-entity/
    ADD artifacts/ /application-entity/artifacts/

You should be able to build the Docker image now using the Docker registry or local build.


