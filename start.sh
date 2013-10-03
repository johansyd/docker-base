#!/bin/bash
# start base image
# sudo docker run -i -p 5300:80 -v ~/src:/home/docker/src -t $image /bin/bash;

sudo docker run $@;

