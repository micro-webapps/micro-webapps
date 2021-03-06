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
# Description: Wait until all webapps become ready, generate the httpd config
# file and start the httpd.

chmod 755 /var/www
chown apache:apache -R /var/www/*

/kubernetes-confd "/etc/httpd/apps.d" "/httpd-cfg /etc/httpd/apps.d /etc/httpd/apps.d" "/usr/sbin/httpd -k graceful" &
/usr/sbin/httpd -D FOREGROUND
