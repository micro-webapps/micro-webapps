# Creating micro-webapps application from existing Nulecule

This document describes how to create micro-webapps web application from existing Nulecule.

## Creating the proper Docker image with web application

There is just single important requirement for the Docker image with web application in order to work properly with micro-webapps and be really useful for the users. The entry point of the Docker image has to be able to deploy the web application in any path and this path has to be configurable by the user.

If your web application listens on "http://localhost/webapp", the Docker image should have a way how to configure the web application to be served from different directory like "http://localhost/somethingelse" or even "http://localhost/".

Ideally, this should be configurable by the environment variable. Usually, the entry point of the Docker image just have to create the new directory in the web-server's document root and move the web application there.

## Adding webconf-spec web-server configuration into existing Kubernetes/Openshift service definition

The [webconf-spec](https://github.com/micro-webapps/webconf-spec) defines the web-server independent configuration of web application.

Let's say we have following service definition:

    {
        "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "webapp-wordpress"
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

The webconf-spec configuration which sets up the reverse proxy for this web application could look like that:

    {
        "virtualhost": "$mwa_vhost",
        "proxy": {
            "url": "http://dummydomain$mwa_alias", 
            "alias": "$mwa_alias"
        }
    }

It just configures the reverse proxy to proxy virtualhost `$mwa_vhost` and path defined by `$mwa_alias` to the Kubernetes/Openshift service running the web application.

The webconf-spec configuration has to be stored into the `metadata` section of the Kubernetes/Openshift service, so the micro-webapps ready service will look like this:

    {
        "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "webapp-wordpress",
            "annotations": {
                "webconf-spec": "{\"virtualhost\": \"$mwa_vhost\",\"proxy\": { \"url\": \"http://dummydomain$mwa_alias\", \"alias\": \"$mwa_alias\"}}"
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

Of course you have to define `$mwa_vhost` and `$mwa_alias` params in the Nulecule file:

        - name: mwa_vhost
          description: >
            Virtual-host where Wordpress should be served.
          default: localhost
        - name: mwa_alias
          description: >
            Alias which should be used to serve the Wordpress.

This is all you have to do in case of simple Nulecule. Your web application can now be used with micro-webapps. In case your web application is using replication controller, please check the next chapter.

## Adding webconf-spec web-server configuration into existing Kubernetes/Openshift replication controller definition

If you are using replication controller for your web application, you have change also the service definition little bit to tell micro-webapps frontend that you are using load balancing. The webconf-spec configuration doing that is following:

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

The newly added `balancers` section tells micro-webapps frontend that you will be using load balancing with round-robin method and the micro-webapps frontend has to generate the cookie to keep the session persistence for your web application. This secures that single user's session is always handled by the same backend.

The `members` list is empty, because it will be populated by the replication controller we will define later in this chapter.

The service definition with the webconf-spec included will look like this:

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

For the replication controller, we will use following webconf-spec configuration:

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

This says, that any new instance of the pod created by the replication controller is member of the `mybalancer` balancer. The `PODIP` string is replaced by the real IP address of the pod automatically when the pod is created.

Again, we have to store this webconf-spec configuration into the replication controller definition, so the replication controller definition will look like this:

    apiVersion: v1
    kind: ReplicationController
    metadata:
      name: webapp-wordpress-controller
    spec:
      replicas: 1
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


This is all you have to do to make the Nulecule with replication controller work with micro-webapps and load balancing.

