# Creating multi-container micro-webapps application - Wordpress with MariaDB example

This document describes how you can create multi-container Nulecule micro-webapps application from the existing Docker image. After reading this document, you should be able to take any Docker image with web-application and make micro-webapps ready Nulecule. We will take Wordpress with MariaDB as an example of multi-container web application, but every step described in this document is quite general and can be applied to any web application.

Before continuing with reading, you should know the [basic micro-webapps architecture](../README.md) and [Creating simple micro-webapps application - Simple Owncloud example](create-simple-owncloud-webapp.md)

## Preparing the Docker image with the web application

There is [official Wordpress Docker image](https://registry.hub.docker.com/_/wordpress/) ready, but we have to tweak it little bit to make it useful with micro-webapps.

The official Wordpress Docker image serves the Wordpress web application in the root directory, but for micro-webapps, we want the path to Wordpress web application to be configurable during deployment. We will create another Docker image based on the official Wordpress Docker image to achieve that. In that Docker image, we will just edit entry point of the official Docker image to copy Wordpress source code into the subdirectory of the deployer choice (based on ENV variable). That way, when Wordpress is deployed, the Wordpress source code is copied into proper subdirectory and is accessible from this subdirectory.

Another problem is that official Wordpress image expects MySQL, but we want it to work with MariaDB. We will therefore do simple replacement of MYSQL_ with MARIADB_ in the entrypoint script.

The last problem with official Docker image is that it uses hostname to connect the SQL database server, but this does not have to work all the time, so we will change it to use the IP address instead.

All of that is achieved by following Dockerfile:

    FROM wordpress:latest

    RUN sed -i 's|set -e|set -e; mkdir -p ".$WORDPRESS_PATH"; chown www-data:www-data -R *; cd ".$WORDPRESS_PATH";|'  /entrypoint.sh
    RUN sed -i "s|WORDPRESS_DB_HOST='mysql'|WORDPRESS_DB_HOST=\"\$MYSQL_PORT_3306_TCP_ADDR\"|" /entrypoint.sh
    RUN sed -i "s|MYSQL_|MARIADB_|" /entrypoint.sh

    ENTRYPOINT ["/entrypoint.sh"]
    CMD ["apache2-foreground"]



This creates the ideal web application image - it serves the web application in the directory which can be choosen during the deployment.

## Creating the Kubernetes or Openshift pod definition for the Wordpress

Now we have to describe the [pod](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/pods.md) file for the Kubernetes and Openshift.

The resulting pod could look like this:

    apiVersion: v1
    kind: Pod
    metadata:
      name: webapp-wordpress
      labels:
        app: webapp-wordpress
    spec:
      containers:
        - name: webapp-wordpress
          image: microwebapps/wordpress
          ports:
            - containerPort: 80
          env:
            - name: WORDPRESS_DB_PASSWORD
              value: $db_password
            - name: WORDPRESS_DB_USER
              value: $db_user
            - name: WORDPRESS_PATH
              value: $mwa_alias

There is nothing special in the pod file. As a base, we are using the `microwebapps/wordpress` Docker image we created earlier. We also let the deployer to configure username and password used to connect the database and path in which Wordpress will be installed inside the image. This is for example "/blog".

## Creating the Kubernetes or Openshift service for Wordpress

The service for Wordpress using the micro-webapps could look like this:

    {
        "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "webapp-wordpress",
            "annotations": {
                "webconf-spec": "{\"virtualhost\": \"$mwa_vhost\",\"proxy\": { \"url\": \"http://webapp$mwa_alias\", \"alias\": \"$mwa_alias\"}}"
            }
        },
        "spec": {
            "selector": {
                "app": "webapp-wordpress"
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

The `webconf-spec` field contains the webserver configuration in the [webconf-spec format](https://github.com/micro-webapps/webconf-spec). If we unescape that part, it looks like this:

    {
        "virtualhost": "$mwa_vhost",
        "proxy": {
            "url": "http://webapp$mwa_alias",
            "alias": "$mwa_alias"
        }
    }

When the Wordpress is deployed, this configuration is stored in the Kubernetes or Openshift API-server and micro-webapps frontend will fetch it and changes its setting to make the Wordpress web application accessible.

In our case, the micro-webapps frontend will proxy the incoming requests from `http://$mwa_vhost$mwa_alias` to the internal backend using the HTTP protocol. It knows the IP address and port from the Kubernetes or Openshift, so we do not have to provide it and just use dummy `webapp` hostname. We have used `$mwa_alias` path in that proxy URL, because the Wordpress is always accessible from the same path on frontend as on the backend (remember our changes done to Wordpress Docker image).

The `$mwa_vhost` and `$mwa_alias` variables are replaced with proper values when the Nulecule we are creating is deployed by the admin.

We will store the service file as `./artifacts/kubernetes/wordpress-service.json`.

## Creating the Nulecule file

Now it's time to create the Nulecule with the pod and service files. Wordpress depends on MariaDB, so we have to include this dependency also in the Nulecule file:

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
      - name: aggregated-mariadb-atomicapp
        source: docker://projectatomic/mariadb-centos7-atomicapp
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
          default: MySQLPass
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

## Deploying the Wordpress micro-webapp

Deployment is described in another article:

  * [Deploying micro-webapps application - Kubernetes](deploy-owncloud-webapp-kubernetes.md)
  * [Deploying micro-webapps application - Openshift](deploy-wordpress-webapp.md)



