#!/usr/bin/env bash
# build  base image
command="$1";


set -o nounset
set -o errtrace
set -o errexit
set -o pipefail

# Text color variables
declare -r txtund=$(tput sgr 0 1) # Underline
declare -r txtbld=$(tput bold) # Bold
declare -r bldred=${txtbld}$(tput setaf 1) # red
declare -r bldblu=${txtbld}$(tput setaf 4) # blue
declare -r bldwht=${txtbld}$(tput setaf 7) # white
declare -r txtrst=$(tput sgr0) # Reset

# make sure we don't leave the terminal with some strange color
trap "printf '%b${txtrst}'" EXIT;

function say () {
    printf "${bldwht}%b${txtrst}\n" "$*";
}

function fail () {
    printf "${bldred}ERROR: %b${txtrst}\n" "$*";
    exit 1;
}

function prompt_yes_no () {
    local choice;
    builtin read -p "${bldblu}$1 (y/n): ${txtrst}" -r choice;
    case $choice in
y|Y) echo "yes";;
n|N) echo "no";;
*) echo "invalid";;
    esac
}

function prompt_string () {
    local answer;

    builtin read -p "${bldblu}$1: ${txtrst}" -r answer;
    if [ ! -z "$answer" ]; then
echo $answer;
return 0;
    else
return 1;
    fi
}

function wait_for_keypress () {
    local answer;
    builtin read -n 1 -p "${bldblu}Press any key to continue${txtrst}" -r answer;
}


function open_url () {
    local -r url=$1;
    
    case "$(uname)" in
Darwin)
open $1;
;;
Linux)
if [ -n $BROWSER ]; then
$BROWSER "$url";
elif which xdg-open > /dev/null; then
xdg-open "$url";
elif which gnome-open > /dev/null; then
gnome-open "$url";
else
fail "Could not detect the web browser to use. Please visit $url manually.\n";
fi
;;
*)
fail "Don't know how to open a browser on this platform. Please visit $url manually.\n";
;;
    esac
}

function abort_not_installed () {
    local -r progname=$1;
    local -r prog_url=$2;

    say "$progname doesn't seem to be installed!\n";
    local answer=$(prompt_yes_no \
"Do you want to visit the $progname website to download and install it?");
    [[ $answer == "yes" ]] && open_url $prog_url;
    say "\nTry running this program again after you have installed $progname!\n";
    exit 2;
}

function abort_too_old () {
    local -r progname=$1;
    local -r prog_url=$2;
    local -r minver=$3;

    say "$progname is too old (need at least $minver)!\n";
    local answer=$(prompt_yes_no \
"Do you want to visit the $progname website to upgrade it?");
    [[ $answer == "yes" ]] && open_url $prog_url;
    say "\nTry running this program again after you have upgraded $progname!\n";
    exit 2;
}

vercomp () {
    if [[ $1 == $2 ]]
    then
return 0
    fi
local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
ver1[i]=0
    done
for ((i=0; i<${#ver1[@]}; i++))
    do
if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
return 1
        fi
if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
return 2
        fi
done
return 0
}

function found () {
    hash $1 2>&-;
}



if [ "$command" != "--image" ]; then
    echo "";
    echo "Usage: build.sh --image <name>";
    echo "";
    exit 0;
fi

image=$2;
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
image_dir="$dir/$image";

if [ ! -d "$image_dir" ]; then
    mkdir $image_dir;
fi

dockerFile="$image_dir/Dockerfile";

if [ ! -f $dockerFile ]; then
    cp $dir/base/Dockerfile $dockerFile;
    echo "";
    echo "The file:$dockerFile did not exist.";
    echo "It was created from base, but please add docker instructions to it.";
    echo "";
fi

sudo docker build -t $image -rm - < $dockerFile;
