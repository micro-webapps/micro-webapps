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

FROM microwebapps/httpd-config
COPY *.json /

COPY *.sh /
RUN chmod +x /*.sh

RUN mkdir -p /usr/share/certificates
RUN yum install openssl mod_ssl -y

VOLUME ["/etc/httpd/apps.d", "/var/www", "/usr/share/certificates"]
CMD ["/run-certs.sh"]
