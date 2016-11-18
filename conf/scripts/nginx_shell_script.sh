#!/usr/bin/env bash

baseFolder="/opt/branch_farm/"
codebaseFolder="${baseFolder}code_base/"
mainBranch="develop"
mainSource="${baseFolder}${mainBranch}"
gitRepo="ssh://git@github.com/river0825/branch_farm"


function log(){
    echo "$(date) ${1}" >> /var/log/branch_farm.log
}

function startDocker(){
	log "startDocker ${1} ${2} ${3} ${4}"
        local folder=${1}
        local port=${2}
        local branch=${3}
        local prefix=${4}

        isDockerUp ${branch}
        up=$?


        log "isDockerUp : ${up}"	
        if [ ${up} == 0 ]; then
            removeDocker ${branch}

            docker run  -d \
                 --name ${prefix}-docker-${branch} \
                 -p "${port}:443" \
                 -v ${folder}:/var/www/html \
                 -v ${folder}/log:/var/log/apache2 \
                 php7
        fi
}

function removeDocker(){
    local branch=$1
    docker ps -a | grep "${branch}" | awk -F" " '{system("docker rm -f " $(NF))}'
}

function rmAllDocker(){
    docker ps -a | grep docker | awk -F " " '{system("docker rm -f "$1)}'
}

function isDockerUp (){
    local _branch=$1
    local exist=$(docker ps | grep "${_branch}" | wc -l)
    return "$exist"
}

#check main folder exists or not
function checkOutMainSource() {
    log "checkoutMainSource"
    if [ ! -d ${mainSource} ]; then
        log "$(git clone ${gitRepo} ${mainSource})"
        setPermission ${mainSource}
        cp ${mainSource}/config/dev.config.ini ${mainSource}/config/config.ini

        startDocker ${mainSource} 10443 ${mainBranch} "dev"
    fi
}

function setPermission(){
    local folder=$1
    log "set permission ${folder}"
    find ${folder} -type d -name "cache" ! -perm 777 -exec chmod 777 {} \;
    chown -R www-data:www-data ${folder}
}

function branchExists () {
    local _branch="origin/"$1
    cd ${mainSource}
    git fetch
    local exist=$(git branch -r | grep "^ *${_branch}$" | wc -l)
    return "$exist"
}

#check out branch
#@var targetFolder
function checkoutBranch(){
    log "checkoutBranch ${1} "
    local branch=${1}
    targetFolder="${codebaseFolder}${branch}"
    if [ ! -d "$targetFolder" ]; then
        log "folder ${targetFolder} not exists, check if branch \"${1}\" exists"
        branchExists $1
        local be=$?
        log "branch exists result: \"${be}\""
        if [ ! "${be}" == 0 ]; then
            log "$branch exists, check it out"
            cp -R ${mainSource} ${targetFolder}
            cd ${targetFolder}
            log "$(git checkout -q $1)"
            log "$(git pull)"

            setPermission ${targetFolder}
        else
            log "branch \"${1}\" not exists!!"
            echo "branch \"${1}\" not exists!!"
            exit 1
        fi
    else
        log "folder ${baseFolder}${1} already exists"
    fi
}


function create () {
    log "create $2 $3"
    if [ -z $2 ]; then
            echo "Usage: ${0} [create|clear] branch port"
            exit 1
    fi

    BRANCH="${1}"
    PORT="${2}"

    checkOutMainSource
    checkoutBranch ${BRANCH}
    startDocker ${targetFolder} ${PORT} ${BRANCH} "branch"
}

function clean () {
    log "clean all"
    rm -rf "${codebaseFolder}*"
    rmAllDocker
    exit 0
}

function git_pull () {
    log "git_pull ${1}"
    local branch=${1}
    local targetFolder="${codebaseFolder}${branch}"

    cd ${targetFolder}
    git pull -X their
}

function init () {
	checkOutMainSource
}

case $1 in
    "clean")
        clean
        ;;
    "create")
        create $2 $3
        ;;
    "pull")
        git_pull $2
        ;;
    "init")
	init
	;;
    *)
        echo "Usage: ${0} [create|clean|pull|init] branch port"
        exit 1
        ;;
esac
