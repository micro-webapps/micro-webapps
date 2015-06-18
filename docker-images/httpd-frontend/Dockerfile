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

FROM centos:7

COPY *.sh /
RUN chmod +x /*.sh

RUN mkdir -p /httpd-cfg-tmp
COPY httpd-cfg /httpd-cfg-tmp
RUN mv /httpd-cfg-tmp/httpd-cfg /
RUN rm -rf /httpd-cfg-tmp
RUN chmod +x /httpd-cfg

RUN mkdir -p /kubernetes-confd-tmp
COPY kubernetes-confd /kubernetes-confd-tmp
RUN mv /kubernetes-confd-tmp/kubernetes-confd /
RUN rm -rf /kubernetes-confd-tmp
RUN chmod +x /kubernetes-confd

RUN yum install httpd mod_ssl -y
RUN echo "IncludeOptional apps.d/*.conf" >> /etc/httpd/conf/httpd.conf

RUN sed -ri ' \
    s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
    s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
    ' /etc/httpd/conf/httpd.conf

VOLUME ["/var/www/", "/var/log/httpd", "/etc/httpd/apps.d"]

Expose 80
Expose 443

CMD ["/run.sh"]
