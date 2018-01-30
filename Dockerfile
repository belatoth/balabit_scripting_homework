FROM centos_base_perl:latest

COPY ./ /docker/

ARG VERSION="<unknown>"
ENV LC_ALL="en_US.UTF-8"

RUN /usr/bin/echo "rss_link_collector v0.0.1" > /version.txt

ENTRYPOINT ["/docker/rss_link_collector.pl"]

LABEL description="This is the rss_link_collector in a Docker container. \
    vendor="belabacsi" \
    name="rss_link_collector"
