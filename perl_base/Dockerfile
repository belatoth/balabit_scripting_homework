FROM centos:centos7

ARG VERSION="<ignore>"

COPY ./ /docker/perl_base/
RUN /docker/perl_base/provision.sh

MAINTAINER bela.social.toth@gmail.com

LABEL description="This is a base image for Perl projects." \
    license="MIT" \
    vendor="nobody" \
    name="Perl Base image"
