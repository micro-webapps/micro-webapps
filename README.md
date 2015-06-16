# What is micro-webapps?
The goal of micro-webapps project is to allow simple deployment of web-apps using Kubernetes. Admin is able to choose set of Docker images with various web-apps, run them as a Kubernetes services and use micro-webapps to set the webserver virtual-host or path on which they should be running.

It is therefore possible to setup webserver with, for example, following structure:

- `http://domain.tld/` running static content.
- `http://domain.tld/blog` running wordpress in separate container.
- `http://bugs.domain.tld` running Bugzilla in separate container.
- `http://another-domain.tld` running completely different domain.

The micro-webapps uses [webconfig-spec](webconfig-spec) to configure the frontend webserver using the configuration installed with the web-app.

# How to use micro-webapps?

The micro-webapps is single Kubernetes pod consisting of two types of containers:

- **httpd-frontend** - Currently the Apache httpd webserver which acts as a proxy for the web-apps.
- **httpd-config-*** - Docker images which configure the httpd-frontend image.

So, to use micro-webapps, admin has to configure Kubernetes services for httpd-frontend and start the Kubernetes pod with single httpd-frontend Docker image and multiple instances of httpd-config-* images.

The following micro-webapps Docker images exist currently:

* [mwa-httpd-frontend](https://registry.hub.docker.com/u/jkaluza/mwa-httpd-frontend/) - Apache httpd frontend image.
* [mwa-httpd-config-generic-proxy](https://registry.hub.docker.com/u/jkaluza/mwa-httpd-config-generic-proxy/) - Generic proxy image for proxying to the various backends.
* [mwa-httpd-config-static](https://registry.hub.docker.com/u/jkaluza/mwa-httpd-config-static/) - Serves static files from Docker volume or files from Git/tarball/rsync in the configured vhost/location.
* [mwa-httpd-config-fpm](https://registry.hub.docker.com/u/jkaluza/mwa-httpd-config-fpm/) - PHP-FPM proxy used for example to proxy to wordpress:fpm Docker image.
* [mwa-httpd-config-ssl](https://registry.hub.docker.com/u/jkaluza/mwa-httpd-config-ssl/) - Configures SSL certificate.

The basic usage is described on the Docker registry page of particular images. You can also check examples described in next section of this page.

# Examples

- [Owncloud](https://github.com/hanzz/micro-webapps/tree/master/examples/owncloud/) - Example showing usage of mwa-httpd-config-generic-proxy with Owncloud to run Owncloud on http://domain.tld/owncloud.
- [Owncloud + static root](https://github.com/hanzz/micro-webapps/tree/master/examples/owncloud-static-root/) - Example showing how to run Owncloud on http://domain.tld/owncloud and static website on the http://domain.tld root.
