# Balabit SCRIPTING ASSIGNMENT

This is a component that identifies links pointing to RSS or Atom feeds written in perl. To avoid the problem because of a dependency issue,
the whole serivce is dockerized.

### To build the docker image perform the following steps:
* clone this repository
* `cd perl_base`
* `docker build -t "centos_base_perl" -f ./Dockerfile .`
* `cd ..` (step into the repo root)
* `docker build -t "rss_link_collector" -f ./Dockerfile .`

## Service usage:
`curl http://www.stylusstudio.com/feeds/ | docker run -i rss_link_collector`
or
`cat example.html | docker run -i rss_link_collector`
