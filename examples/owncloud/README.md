# Owncloud example

This example shows how to use micro-webapps to serve Owncloud on http://domain.tld/owncloud.

This example includes four files:

- **00-httpd-frontend.yaml** - definition of httpd-frontend Kubernetes pod.
- **00-webapp-owncloud.yaml** - definition of Owncloud web-app Kubernetes pod.
- **10-httpd-frontend-service.json** - definition of httpd-frontend Kubernetes service.
- **10-webapp-owncloud-service.json** - definition of owncloud web-app Kubernetes service.

You can find them in this directory or [here](https://github.com/hanzz/micro-webapps/tree/master/examples/owncloud).
