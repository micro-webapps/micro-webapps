# Deploying the micro-webapps application - Owncloud example

This document describes how you can deploy Nulecule based micro-webapps application using Kubernetes.

Before continuing with reading, you should know the [basic micro-webapps architecture](../README.md).

## Deploying the micro-webapps frontend

At first, we have to deploy the micro-webapps frontend. The frontend will act as a proxy between the web application users and the web application's containers. The frontend is shared between all micro-webapps applications, so you have to deploy the frontend just once.

There are multiple frontends available (currently the Apache httpd, HAProxy and nginx), so you have to choose one. We will use the HAProxy frontend (haproxy-frontend) in this document, but you can just use httpd-frontend or nginx-frontend instead, all the configuration remains the same.

With the Atomicapp, you can deploy the haproxy-frontend simply by executing following command:

    atomicapp -a answers.conf run microwebapps/haproxy-frontend-atomicapp

It will ask for various deployment-related information:

* *kubernetes_client_certificate* - Client certificate to access Kubernetes/Openshift API with new-lines escaped to "\n". This can be done by sed ':a;N;$!ba;s/\n/\\n/g'. Set to None if no certificate is needed.
* *kubernetes_client_key* - Client key to access Kubernetes API with new-lines escaped to "\n". This can be done by sed ':a;N;$!ba;s/\n/\\n/g'. Set to None if no key is needed.

This is not needed by default unless you want the frontend container to validate the Kubernetes API server certificate. We won't do that in this document.

Last question is:

* *publicip* - The IP address or addresses at which haproxy can be reached.

After that, you should see following output for `kubectl get pods`:

    POD                IP            CONTAINER(S)       IMAGE(S)                        HOST           LABELS                  STATUS    CREATED
    haproxy-frontend   172.17.0.19   haproxy-frontend   microwebapps/haproxy-frontend   ose3-atomic/   name=haproxy-frontend   Running   45 seconds

And following output for `kubectl get services1`:

    NAME                       LABELS                                    SELECTOR                IP               PORT(S)
    haproxy-frontend-service   <none>                                    name=haproxy-frontend   172.30.239.242   80/TCP
                                                                                                 10.0.0.1         443/TCP
You can also try to use `curl` to check the haproxy-frontend is answering the requests:

    $ curl 172.30.239.242
    <html><body><h1>503 Service Unavailable</h1>
    No server is available to handle this request.
    </body></html>

This output is OK, because we don't have any web application deployed yet.

## Depoying the Owncloud micro-webapps

Similarly to micro-webapps frontend, we will deploy the Ownclod web application now on `http://domain.tld/owncloud` URL. You could use any URL (even just the hostname without any path) instead.

We will use the answers.conf file to define the virtualhost and alias of the Owncloud instance using the `mwa_vhost` and `mwa_alias` variables:

    [webapp-owncloud]
    mwa_alias = /owncloud
    mwa_vhost = domain.tld
    [general]
    namespace = default
    provider = kubernetes

To deploy the Owncloud, all we have to do now is to execute following atomicapp command:

    atomicapp -a answers.conf run microwebapps/webapp-owncloud-atomicapp

After that, you should see following output for `kubectl get pods`:

    POD                IP            CONTAINER(S)       IMAGE(S)                        HOST           LABELS                  STATUS    CREATED
    haproxy-frontend   172.17.0.19   haproxy-frontend   microwebapps/haproxy-frontend   ose3-atomic/   name=haproxy-frontend   Running   13 minutes
    mysql              172.17.0.22   mysql              mysql                           ose3-atomic/   name=mysql              Running   25 seconds
    webapp-wordpress   172.17.0.23   webapp-wordpress   microwebapps/wordpress          ose3-atomic/   name=webapp-wordpress   Running   24 seconds

And following output for `kubectl get services`:

    NAME                       LABELS                                    SELECTOR                IP               PORT(S)
    haproxy-frontend-service   <none>                                    name=haproxy-frontend   172.30.239.242   80/TCP
                                                                                                 10.0.0.1         443/TCP
    mysql                      name=mysql                                name=mysql              172.30.171.16    3306/TCP
    webapp-wordpress           <none>                                    name=webapp-wordpress   172.30.63.191    80/TCP

You can also try to use `curl` to check the haproxy-frontend is proxying the requests to Owncloud:

    $ curl -H "Host: domain.tld" http://172.30.239.242/blog/wp-admin/install.php 2>/dev/null | grep WordPress  
            <title>WordPress &rsaquo; Installation</title>

