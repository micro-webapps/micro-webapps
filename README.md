Table of Contents
=================

  * [What is micro-webapps?](#what-is-micro-webapps)
  * [Micro-webapps architecture](#micro-webapps-architecture)
  * [Micro-webapps frontends](#micro-webapps-frontends)
  * [Micro-webapps with Nulecule](#micro-webapps-with-nulecule)
    * [Nulecule examples](#nulecule-examples)
  * [Microwebapps without Nulecule](#microwebapps-without-nulecule)
  * [Documentation](#documentation)

# What is micro-webapps?
The goal of the micro-webapps project is to allow simple deployment of web applications in the cloud (multi container) environment. Admin is able to choose the frontend which will serve the web applications and then install the web-applications as separate containers. For each web application, he is able to configure the URI on which the web application will be served.

It is therefore possible to setup webserver with, for example, following structure:

- `http://domain.tld/` running static content.
- `http://domain.tld/blog` running wordpress in separate container.
- `http://bugs.domain.tld` running Bugzilla in separate container.
- `http://another-domain.tld` running completely different domain.

# Micro-webapps architecture

The basic architecture of micro-webapps is ilustrated by this image:

![Micro-webapps architecture](graphics/architecture.png)

Web applications are running in separate containers using the Kubernetes, Openshift, Docker or another container environment. When started, the web application publishes its webserver related configuration into some shared storage. This can be Kubernetes or Openshift API-server or for example the Docker shared volume.

The webserver configuration published by the web application is in the webserver-independent [webconfig-spec](https://github.com/hanzz/micro-webapps/blob/master/webconfig-spec/README.md) JSON format. This has multiple benefits:

- The developer of the web application writes single webserver configuration file and can be sure it will work with all the frontend webservers.
- The deployer of the web application can use whatever frontend webserver he wants.
- When the new webserver is created, the web applications do not have to be changed. There only have to exist the webconfig-spec loader plugin for the webserver.

When the webserver configuration is published in the shared storage, the frontend webserver detects it and reload its configuration to reflect the configuration of newly added web application. This allows transparent changes in the served applications and virtualhost.

Later, when the client sends a request for the particular web application, the frontend webserver forwards it to the right container according to the frontend webserver configuration.

# Micro-webapps frontends

Currently, there are following micro-webapps frontends:

- [htpd-frontend](https://registry.hub.docker.com/u/microwebapps/httpd-frontend/) - Apache httpd frontend.
- [haproxy-frontend](https://registry.hub.docker.com/u/microwebapps/haproxy-frontend/) - HAProxy frontend.

For the `httpd-frontend`, there exists extra `httpd-config-*` Docker images. These Docker images are used to inject extra configuration into the httpd-frontend container, so it is for example possible to serve static data on the particular virtualhost.

The following extra, httpd-frontend only, images exist:
* [mwa-httpd-frontend](https://registry.hub.docker.com/u/microwebapps/mwa-httpd-frontend/) - Apache httpd frontend image.
* [mwa-httpd-config-generic-proxy](https://registry.hub.docker.com/u/microwebapps/mwa-httpd-config-generic-proxy/) - Generic proxy image for proxying to the various backends.
* [mwa-httpd-config-static](https://registry.hub.docker.com/u/microwebapps/mwa-httpd-config-static/) - Serves static files from Docker volume or files from Git/tarball/rsync in the configured vhost/location.
* [mwa-httpd-config-fpm](https://registry.hub.docker.com/u/microwebapps/mwa-httpd-config-fpm/) - PHP-FPM proxy used for example to proxy to wordpress:fpm Docker image.
* [mwa-httpd-config-ssl](https://registry.hub.docker.com/u/microwebapps/mwa-httpd-config-ssl/) - Configures SSL certificate.

The basic usage is described on the Docker registry page of particular images.

# Micro-webapps with Nulecule

Using the [Nulecule](https://github.com/projectatomic/nulecule/) specification and its reference implementation - [The atomicapp project](https://github.com/projectatomic/atomicapp). It is possible to use micro-webapps for development, packaging and deployment of fully modular and self-contained web applications.

The developer of the web application can create single Docker image, which will deploy the application on all container environments and let the deployer to easily decide on which URI the web-application should be running. In the end of deployment, the deployer has fully working web-application without the need to touch the web application's the frontend's configuration file.

## Nulecule examples

- [Owncloud](https://github.com/micro-webapps/micro-webapps/tree/master/nulecules/owncloud) - Example showing the Owncloud web application using the micro-webapps and Nulecule.

# Microwebapps without Nulecule

*NOTE: This section is not up-to-date. The following examples has to be ported to new micro-webapps architecture. They are still valid when it comes to usage of webconfig-spec, but they are not using shared storage for storing the webserver configuration files. Better stop reading here to not get confused... :)*

It is also possible to use micro-webapps without the Nulecule project. Following examples are showing how to use the micro-webapps with the Kubernetes project:

- [Owncloud](https://github.com/micro-webapps/micro-webapps/tree/master/examples/owncloud/) - Example showing usage of httpd-config-generic-proxy with Owncloud to run Owncloud on http://domain.tld/owncloud.
- [Owncloud + static root](https://github.com/micro-webapps/micro-webapps/tree/master/examples/owncloud-static-root/) - Example showing how to run Owncloud on http://domain.tld/owncloud and static website on the http://domain.tld root.

# Documentation

This chapter contains useful documentation and examples how to use micro-webapps.

  * Nulecule - Atomicapp
    * [Creating the micro-webapps application - Wordpress example](docs/create-wordpress-webapp.md)
