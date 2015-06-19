# Frequently asked questions

* [What is the difference between micro-webapps and Kubernetes service](#what-is-the-difference-between-micro-webapps-and-kubernetes-service)
* [What is the difference between micro-webapps and Openshift3 routing layer](#what-is-the-difference-between-micro-webapps-and-openshift3-routing-layer)

## What is the difference between micro-webapps and Kubernetes service

A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them. The micro-webapps is a way how to give the web-related configuration to Kubernetes service and let other parts of the cloud to discover this configuration and handle it. This can be done by one of the micro-webapps frontend or even some cloud components.

## What is the difference between micro-webapps and Openshift3 routing layer

Micro-webapps is trying to propose single format for the webserver related configuration - [webconf-spec](https://github.com/micro-webapps/webconf-spec). In the cloud, there is always a need for reverse proxy or load balancer to make the web applications accessible for the end users. The Openshift3 routing layer allows that (using HAProxy internally), but currently this is tight to Openshift3 and the web application developer has to define separate routing configuration just for Openshift3.

On the otherside, micro-webapps allows the web application developer to define just single webserver configuration (or if you wish - single "routing configuration") which will work everywhere. This is currently ensured by usage of httpd-frontend or haproxy-frontend micro-webapps frontends, but in the future, the Openshift3 routing layer could support loading of webconf-spec configuration and therefore for Openshift3, the micro-webapps frontends would not have to be used.

Another difference between micro-webapps and Openshift3 routing layer is that the Openshift3 routing describes only routing, while the micro-webapps allows the web application developer to define full-featured webserver configuration. Sure, if the deployer later uses frontend software which does not support all the features, he won't get them, but it is possible to describe them for the web application developer.

One example of the configuration using full-featured webserver is the php-fpm container running wordpress and the httpd-frontend forwarding *only* requests for PHP files to the php-fpm container. This is not possible to do using current Openshift3 routing layer design, but it is good way how to deploy multi-container PHP applications.
