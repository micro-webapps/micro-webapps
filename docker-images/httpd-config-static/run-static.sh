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
# Description: Prepares configuration for serving static data.

UUID=`uuidgen`
export "DIR_UUID=$UUID"

mkdir /var/www/html
mkdir /var/www/${UUID}
cd /var/www/${UUID}

STATIC_DATA_URL=$(printenv MWA_STATIC_DATA_URL)

FILE_COUNT=$(ls /usr/share/static-data|wc -l)
if [ $FILE_COUNT != 0 ]
then 
    STATIC_DATA_URL="/usr/share/static-data/"
fi 

echo "${STATIC_DATA_URL}"|grep "^git://\|.git$" >/dev/null
if [ $? == 0 ]; then
    git clone "$STATIC_DATA_URL" ../${UUID}
else
    echo "${STATIC_DATA_URL}"|grep ".tgz$\|.tar.gz$|" >/dev/null
    if [ $? == 0 ]; then
        wget "$STATIC_DATA_URL"
        tar -xf *
    else
        rsync -av "${STATIC_DATA_URL}" .
    fi
fi

/copy-json / /etc/httpd/apps.d
while : ; do
    echo 1 > "/etc/httpd/apps.d/${UUID}.done"

    echo "${STATIC_DATA_URL}"|grep "^git://\|.git$" >/dev/null
    if [ $? == 0 ]; then
        git pull
    fi

    sleep 1
done

