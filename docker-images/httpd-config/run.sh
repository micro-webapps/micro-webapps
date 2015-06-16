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
# Description: Copies json config files into /etc/httpd/apps.d
# and writes the ${UUID}.done file to /etc/httpd/apps.d to inform
# the httpd-frontend, that all json files are successfully copied.

UUID=`uuidgen`

mkdir /var/www/html
/copy-json / /etc/httpd/apps.d
while : ; do
    echo 1 > "/etc/httpd/apps.d/${UUID}.done"
    sleep 1
done

