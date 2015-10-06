# Deploying the micro-webapps application - Wordpress example

This document describes how you can deploy Nulecule based micro-webapps application on Kubernetes or Openshift using Atomic App.

Before continuing with reading, you should know the [basic micro-webapps architecture](../README.md).

## Deploying the micro-webapps frontend

At first, we have to deploy the micro-webapps frontend. The frontend will act as a proxy between the web application users and the web application's containers. The frontend is shared between all micro-webapps applications, so you have to deploy the frontend just once.

There are multiple frontends available (currently the Apache httpd, HAProxy and nginx), so you have to choose one. We will use the httpd frontend (httpd-frontend) in this document, but you can just use haproxy-frontend or nginx-frontend instead, all the configuration remains the same.

With the Atomicapp, you can deploy the httpd-frontend simply by executing following command:

    # atomicapp -a answers.conf run microwebapps/httpd-frontend-atomicapp

It will ask for various deployment-related information:

* *kubernetes_client_certificate* - Client certificate to access Kubernetes/Openshift API with new-lines escaped to "\n". This can be done by sed ':a;N;$!ba;s/\n/\\n/g'. Set to None if no certificate is needed.
* *kubernetes_client_key* - Client key to access Kubernetes API with new-lines escaped to "\n". This can be done by sed ':a;N;$!ba;s/\n/\\n/g'. Set to None if no key is needed.

This is not needed by default unless you want the frontend container to validate the Kubernetes API server certificate. We won't do that in this document.

Last question is:

* *publicip* - The IP address or addresses at which httpd-frontend can be reached.

If you just want to test micro-webapps on your local network, you don't have to fill `publicip`.

After that, you should see following output for `kubectl get pods` or `osc get pods`:

    NAME             READY     STATUS    RESTARTS   AGE
    httpd-frontend   1/1       Running   0          16s

And following output for `kubectl get services` or `osc get services`:

    NAME                     LABELS                                    SELECTOR             IP(S)            PORT(S)   AGE
    httpd-frontend-service   <none>                                    app=httpd-frontend   192.168.218.19   80/TCP    36s
                                                                                                            443/TCP
You can also try to use `curl` to check the httpd-frontend is answering the requests:

    $ curl 192.168.218.19
    ...

It should output the default httpd test page.

## Deploying the Wordpress micro-webapp

Similarly to micro-webapps frontend, we will deploy the Wordpress web application now on `http://domain.tld/blog` URL. You could use any URL (even just the hostname without any path) instead.

We will use the `answers.conf` file to define the virtualhost and alias of the Wordpress instance using the `mwa_vhost` and `mwa_alias` variables:

    [wordpress]
    mwa_alias = /blog
    mwa_vhost = domain.tld
    mwa_replicas = 1
    [general]
    namespace = default
    provider = kubernetes

To deploy the Wordpress, all we have to do now is to execute following atomicapp command:

    # atomicapp -a answers.conf run microwebapps/wordpress-atomicapp

It will ask various questions about MariaDB database - for them, just keep the default values, because we are using default database deployed together with the Wordpress Atomic App, so there's no need to change anything.

After that, you should see following output for `kubectl get pods` or `osc get pods`:

    NAME                                READY     STATUS    RESTARTS   AGE
    httpd-frontend                      1/1       Running   0          16m
    mariadb                             1/1       Running   0          1m
    webapp-wordpress-controller-8i5km   1/1       Running   0          1m

And following output for `kubectl get services` or `osc get services`:

    NAME                     LABELS                                    SELECTOR               IP(S)             PORT(S)   AGE
    httpd-frontend-service   <none>                                    app=httpd-frontend     192.168.218.19    80/TCP    16m
                                                                                                                443/TCP
    mariadb                  name=mariadb                              name=mariadb           192.168.98.176    3306/TCP   44s
    webapp-wordpress         <none>                                    app=webapp-wordpress   192.168.189.180   80/TCP     44s

You can also try to use `curl` to check the haproxy-frontend is proxying the requests to Owncloud:

    $ curl -H "Host: domain.tld" http://192.168.218.19/blog/wp-admin/install.php 2>/dev/null | grep WordPress  
            <title>WordPress &rsaquo; Installation</title>

