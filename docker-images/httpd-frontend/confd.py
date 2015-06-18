#!/usr/bin/env python
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: Jan Kaluza <jkaluza at redhat dot com>
# Description: Watch for new web-apps using the Kubernetes API, regenerates
# the config files and gracefully reload httpd.

from __future__ import print_function
from urlparse import urlparse
import sys
import json
import os
import httplib
import time
import uuid

old_services = []


def needs_regeneration(cfg):                                                                                                                                                                                                                 
    global old_services
    services = []
    for item in cfg["items"]:
        if not item.has_key("annotations") or not item["annotations"].has_key("webconf-spec"):
            continue
        services.append(item)

    if old_services == services:
        return False
    old_services = services
    return True

def generate_config(kube_host, kube_port, key_file, cert_file, kube_namespace):
    conn = httplib.HTTPSConnection(kube_host, kube_port, key_file, cert_file)
    if kube_namespace:
        conn.request("GET", "/api/v1beta1/services?namespace=" + kube_namespace)
    else:
        conn.request("GET", "/api/v1beta1/services/")
    response = conn.getresponse(buffering=True)
    if response.status != 200:
        print(response.status, response.read())
        return

    cfg = json.load(response)
    if not needs_regeneration(cfg):
        return

    os.system("rm -f /etc/httpd/apps.d/*")
    envcmd = ""

    for item in cfg["items"]:
        if not item.has_key("annotations") or not item["annotations"].has_key("webconf-spec"):
            continue

        webconfig = item["annotations"]["webconf-spec"]
        item["webconfig"] = json.loads(webconfig)
        print(item)

        envcmd += "export "
        envcmd += item["id"].upper().replace("-", "_") + "_PORT="
        envcmd += "tcp://" + item["portalIP"] + ":" + str(item["port"])
        envcmd += "; "

        f = open("/etc/httpd/apps.d/" + item["uid"] + ".json", "w")
        json.dump(item, f)
        f.close()
        del item["webconfig"]

    print (envcmd + " /httpd-cfg /etc/httpd/apps.d /etc/httpd/apps.d")
    os.system(envcmd + " /httpd-cfg /etc/httpd/apps.d /etc/httpd/apps.d")
    os.system("/usr/sbin/httpd -k graceful")

def getenv_as_file(name, default):
    data = os.getenv(name + "_DATA", default)
    if data == default:
        data = os.getenv(name + "_FILE", default)
        if data == "None":
            return None
    if data == "None":
        return None

    filename = "/" + str(uuid.uuid1())
    f = open(filename, "w")
    f.write(data.replace("\\n", "\n"))
    f.close()
    return filename

def main():
    kube_host = os.getenv("KUBERNETES_SERVICE_HOST", False)
    kube_port = os.getenv("KUBERNETES_SERVICE_PORT", False)
    kube_namespace = os.getenv("KUBERNETES_NAMESPACE", False)
    cert_file = getenv_as_file("KUBERNETES_CLIENT_CERTIFICATE", None)
    key_file = getenv_as_file("KUBERNETES_CLIENT_KEY", None)

    if kube_host == False or kube_port == False:
        print("KUBERNETES_SERVICE_HOST or KUBERNETES_SERVICE_PORT not set, exiting")
        return 1

    while True:
        time.sleep(2)
        generate_config(kube_host, kube_port, key_file, cert_file, kube_namespace)
        time.sleep(5)

    return 0

sys.exit(main())
