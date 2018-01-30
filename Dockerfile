FROM centos_base_perl:latest

COPY ./ /docker/

# set some env variables (those currently defined in /etc/sysconfig/httpd, and shouldn't be changed).
ARG VERSION="<unknown>"
ENV LC_ALL="en_US.UTF-8"

RUN /usr/bin/echo "rss_link_collector v0.0.1" > /version.txt

ENTRYPOINT ["/docker/rss_link_collector.pl"]

LABEL description="This is the rss_link_collector, running in a Docker container. \
    license="MIT" \
    vendor="nobody" \
    name="rss_link_collector"
