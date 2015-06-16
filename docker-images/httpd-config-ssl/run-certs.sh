#!/bin/bash
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
# Description: Uses following environment variables to prepare httpd-frontend
# configuration for SSL website:
# - MWA_CERTIFICATE
# - MWA_CERITIFCATE_KEY
# - MWA_DOMAIN
# - MWA_REDIRECT_HTTP

UUID=`uuidgen`
export "DIR_UUID=$UUID"

mkdir /var/www/html
mkdir /etc/httpd/apps.d/${UUID}

MWA_CERTIFICATE=$(printenv MWA_CERTIFICATE)
MWA_CERTIFICATE_KEY=$(printenv MWA_CERTIFICATE_KEY)
MWA_DOMAIN=$(printenv MWA_DOMAIN)
MWA_REDIRECT_HTTP=$(printenv MWA_REDIRECT_HTTP)

# If MWA_CERTIFICATE is not set, presume that certificates are stored
# in /usr/share/certificates and are named according to MWA_DOMAIN.
if [ "${MWA_CERTIFICATE}x" == "x" ]
then
    cd /usr/share/certificates
    /gencert.sh "${MWA_DOMAIN}"
    MWA_CERTIFICATE="${MWA_DOMAIN}.crt"
    MWA_CERTIFICATE_KEY="${MWA_DOMAIN}.key"
fi

cd /etc/httpd/apps.d/${UUID}

# Copy the certificates to /etc/httpd/apps.d/$UUID
FILE_COUNT=$(ls /usr/share/certificates|wc -l)
if [ $FILE_COUNT != 0 ]
then
    cp /usr/share/certificates/* .
else
    wget "${MWA_CERTIFICATE}"
    wget "${MWA_CERTIFICATE_KEY}"
fi

export "MWA_CERTIFICATE=/etc/httpd/apps.d/${UUID}/`basename ${MWA_CERTIFICATE}`"
export "MWA_CERTIFICATE_KEY=/etc/httpd/apps.d/${UUID}/`basename ${MWA_CERTIFICATE_KEY}`"

# When redirecting http:// to https://, make the proper redirection
if [ "${MWA_REDIRECT_HTTP}x" != "x" ]
then
    export MWA_REDIRECT_HTTP="/ https://\$MWA_VHOST\$"
fi

/copy-json / /etc/httpd/apps.d
while : ; do
    echo 1 > "/etc/httpd/apps.d/${UUID}.done"
    sleep 1
done

