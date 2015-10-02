# Creating micro-webapps application with replication and load balancing - Wordpress example

This document describes how to create multi-container Nulecule micro-webapps application with load balancing support from the existing Docker image. We will take Wordpress with MariaDB as an example of multi-container web application, but every step described in this document is quite general and can be applied to any web application.

Before continuing with reading, you should know the [basic micro-webapps architecture](../README.md), [Creating simple micro-webapps application - Simple Owncloud example](create-simple-owncloud-webapp.md) and [Creating multi-container micro-webapps application - Wordpress with MariaDB example](create-multi-container-wordpress-webapp.md)

## Preparing the Docker image with the web application

We will base our work on the Wordpress Docker image we have created as part of [Creating multi-container micro-webapps application - Wordpress with MariaDB example](create-multi-container-wordpress-webapp.md). This image is also stored in the official Docker registry as `microwebapps/wordpress`.

## Creating the Kubernetes or Openshift replication controller definition for the Wordpress

This time we won't create pod file, but we will create replication controller instead:

    apiVersion: v1
    kind: ReplicationController
    metadata:
      name: webapp-wordpress-controller
    spec:
      replicas: $mwa_replicas
      # selector identifies the set of pods that this
      # replication controller is responsible for managing
      selector:
        app: webapp-wordpress
      # template defines the 'cookie cutter' used for creating
      # new pods when necessary
      template:
        metadata:
          name: webapp-wordpress
          labels:
            app: webapp-wordpress
          annotations:
            webconf-spec: "{\"virtualhost\": \"$mwa_vhost\", \"balancers\": { \"mybalancer\": { \"members\": [{\"url\": \"http://PODIP\"}]} }}"
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

The special part of this replication controller definition is the annotations part containing the webconf-spec:

    {
        "virtualhost": "$mwa_vhost",
        "balancers": {
            "mybalancer": {
                "members": [
                    {
                        "url": "http://PODIP"
                    }
                ]
            }
        }
    }

When new pod is created by this replication controller, it contains this webconf-spec configuration. This configuration says that this pod should be added to list of members of balancer called `mybalancer` in virtualhost defined by `$mwa_vhost`. The `PODIP` string is replaced by the micro-webapps frontend by the real IP address of the pod.

## Creating the Kubernetes or Openshift service for Wordpress

The service for Wordpress using the micro-webapps could look like this:

{
    "kind": "Service",
    "apiVersion": "v1",
    "metadata": {
        "name": "webapp-wordpress",
        "annotations": {
            "webconf-spec": "{\"virtualhost\": \"$mwa_vhost\",\"proxy\": { \"url\": \"balancer://mybalancer$mwa_alias\", \"alias\": \"$mwa_alias\"}, \"balancers\": { \"mybalancer\": { \"method\": \"round-robin\", \"persistence\": { \"method\": \"generate_cookie\", \"cookie_name\": \"ROUTEID\", \"url_id\": \"routeid\"}, \"members\": []} }}"
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
            "url": "balancer://mybalancer$mwa_alias", 
            "alias": "$mwa_alias"
        },
        "balancers": {
            "mybalancer": {
                "method": "round-robin",
                "persistence": {
                    "method": "generate_cookie",
                    "cookie_name": "ROUTEID",
                    "url_id": "routeid"
                },
                "members": []
            }
        }
    }

The new part is the `balancers` part. It configures the load balancing - its method, the method of persistence and members. The list of members is empty, because it will be populated dynamically when new backends are created by the replication controller.

We will store the service file as `./artifacts/kubernetes/wordpress-service.json`.

## Creating the Nulecule file and Dockerfile

The Nulecule file and Dockerfile are the same as in the [Creating multi-container micro-webapps application - Wordpress with MariaDB example](create-multi-container-wordpress-webapp.md).

## Deploying the Wordpress micro-webapp

Deployment is described in another article:

  * [Deploying micro-webapps application - Kubernetes](deploy-owncloud-webapp-kubernetes.md)
  * [Deploying micro-webapps application - Openshift](deploy-wordpress-webapp.md)



