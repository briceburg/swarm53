FROM alpine:3.6
RUN apk --no-cache add bash curl groff python py-pip &&\
  pip install --upgrade awscli==1.14.19 &&\
  apk --purge del py-pip

COPY src/swarm53.sh /usr/bin/swarm53
ENV PAGER="more"
ENTRYPOINT ["swarm53"]
