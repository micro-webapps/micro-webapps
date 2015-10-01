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

FROM wordpress:latest

RUN sed -i 's|set -e|set -e; mkdir -p ".$WORDPRESS_PATH"; chown www-data:www-data -R *; cd ".$WORDPRESS_PATH";|'  /entrypoint.sh
RUN sed -i "s|WORDPRESS_DB_HOST='mysql'|WORDPRESS_DB_HOST=\"\$MYSQL_PORT_3306_TCP_ADDR\"|" /entrypoint.sh
RUN sed -i "s|MYSQL_|MARIADB_|" /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]