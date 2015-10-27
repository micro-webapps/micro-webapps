FROM projectatomic/atomicapp:0.1.12

MAINTAINER Jan Kaluza <jkaluza@redhat.com>

LABEL io.projectatomic.nulecule.specversion="0.0.2" \
      io.projectatomic.nulecule.providers="kubernetes, openshift" \
      Build="docker build --rm --tag test/httpd-frontend-atomicapp ."

ADD /Nulecule /Dockerfile /application-entity/
ADD /artifacts /application-entity/artifacts
