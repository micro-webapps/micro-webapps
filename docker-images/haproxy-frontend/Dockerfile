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

FROM haproxy:1.5

COPY *.sh /
RUN chmod +x /*.sh

RUN mkdir -p /haproxy-cfg-tmp
COPY haproxy-cfg /haproxy-cfg-tmp
RUN mv /haproxy-cfg-tmp/haproxy-cfg /
RUN rm -rf /haproxy-cfg-tmp
RUN chmod +x /haproxy-cfg

RUN mkdir -p /kubernetes-confd-tmp
COPY kubernetes-confd /kubernetes-confd-tmp
RUN mv /kubernetes-confd-tmp/kubernetes-confd /
RUN rm -rf /kubernetes-confd-tmp
RUN chmod +x /kubernetes-confd

RUN touch /usr/local/etc/haproxy/haproxy.cfg

RUN apt-get update && apt-get install -y python psmisc

Expose 80
Expose 443

CMD ["/run.sh"]
