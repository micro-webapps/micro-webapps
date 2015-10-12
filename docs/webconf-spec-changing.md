# Changing webconf-spec configuration

This document describes how to change webconf-spec configuration stored together with micro-webapp application in Atomic App or plain Kubernetes/Openshift.

## Getting the webconf-spec configuration from Kubernetes/Openshift artifacts

When using Atomic App, you can find out the Kubernetes or Openshift Artifacts in the `./artifacts/kubernestes` subdirectory of directory from where you installed the Atomic App.

When you open Kubernetes/Openshift artifact, you can find out the webconf-spec definition in the `metadata` -> `annotations` -> `webconf-spec` section. Webconf-spec is stored there as an escaped string like this:

    {\"virtualhost\": \"$mwa_vhost\",\"proxy\": { \"url\": \"balancer://gitlabbalancer$mwa_alias\", \"alias\": \"$mwa_alias\"}, \"balancers\": { \"gitlabbalancer\": { \"method\": \"round-robin\", \"persistence\": { \"method\": \"generate_cookie\", \"cookie_name\": \"JSESSIONID\", \"url_id\": \"jsessionid\"}, \"members\": []} }}

Using the [jq](https://stedolan.github.io/jq/), it is quite easy to get the webconf-spec from the Kubernetes Service artifact:

```
$ jq '.metadata.annotations["webconf-spec"]' service.json | sed -r 's/\\(.)/\1/g' | rev | cut -c2- | rev | cut -c2- | jq . > webconf-spec.json
$ cat webconf-spec.json
{
  "balancers": {
    "gitlabbalancer": {
      "members": [],
      "persistence": {
        "url_id": "jsessionid",
        "cookie_name": "JSESSIONID",
        "method": "generate_cookie"
      },
      "method": "round-robin"
    }
  },
  "proxy": {
    "alias": "$mwa_alias",
    "url": "balancer://gitlabbalancer$mwa_alias"
  },
  "virtualhost": "$mwa_vhost"
}
```

For replication controllers, you can get the webconf-spec configuration using jq like this:

```
$ jq '.spec.template.metadata.annotations["webconf-spec"]' gitlab-rc.json | sed -r 's/\\(.)/\1/g' | rev | cut -c2- | rev | cut -c2- | jq . > webconf-spec.json
$ cat webconf-spec.json
{
  "balancers": {
    "gitlabbalancer": {
      "members": [
        {
          "url": "http://PODIP"
        }
      ]
    }
  },
  "virtualhost": "$mwa_vhost"
}
```

## Editing the webconf-spec configuration

Edit the `webconf-spec.json` file you get by following the previous chapter and once you are done, simply run following `jq` command to generate the webconf-spec field for the Kubernetes/Openshift artifact:

```
$ jq @json webconf-spec.json 
"{\"virtualhost\":\"$mwa_vhost\",\"proxy\":{\"url\":\"balancer://gitlabbalancer$mwa_alias\",\"alias\":\"$mwa_alias\"},\"balancers\":{\"gitlabbalancer\":{\"method\":\"round-robin\",\"persistence\":{\"method\":\"generate_cookie\",\"cookie_name\":\"JSESSIONID\",\"url_id\":\"jsessionid\"},\"members\":[]}}}"
```

You can now use the output of jq command as new value for `webconf-spec` field in the Kubernetes artifact.
