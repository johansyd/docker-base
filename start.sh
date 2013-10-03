#!/bin/bash
# start base image
# sudo docker run -i -p 5300:80 -v ~/src:/home/docker/src -t $image /bin/bash;

    image=  port=  src=  
    while getopts i:p:s: opt; do
        case $opt in
        i)
            image=$OPTARG
            ;;
        p)
            port=$OPTARG
            ;;
        s)
            src=$OPTARG
            ;;
        *)
                break
                ;;
        esac 
    done;
    shift $((OPTIND - 1));

if [ -z $image ] || [ -z $port ] || [ -z $src ]; then
    echo "";
    echo "Usage: start.sh -i <hostname and image name> -p <port to webserver> -s <directory to mount>"
    exit 0;
fi

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
image_dir="$dir/.$image";

if [ ! -d "$image_dir" ]; then
    $dir/build.sh --image $image;
fi

if [ ! -d "$src" ]; then
    mkdir $src;
fi

sudo docker run -i -p $port:80 -v $src:/home/docker/src -h $image -t $image /bin/bash;
exit 1;
