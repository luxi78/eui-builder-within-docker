#!/bin/bash
#
# script file that maps itself into a docker container and runs
#
# Example invocation:
#
# $ AOSP_VOL=$PWD/build ./build-in-docker.sh
#
# 环境变量：
#   AOSP_VOL: 指定aosp-root目录
#        其下会有aosp和ccache两个目录，分别是android源码根目录和编译缓存
#        如果此目录不存在则自动创建
#        如不指定，则默认路径是当前目录下的aosp-root
#   
#   AOSP_VERSION:
#        marshmallow  选取编译m的容器
#        nougat       选取编译n的容器
#
#   DOCKER_RUN_SCRIPT:
#       docker中需要运行的脚本的文件名，
#        所有脚本均放在scripts目录下


#set -ex
set -e

if [ "$1" = "docker" ]; then #代码在docker中运行,当前目录已经在/aosp下（即android源码的根目录下)
    #TEST_BRANCH=${TEST_BRANCH:-android-7.0.0_r14}
    #TEST_URL=${TEST_URL:-https://aosp.tuna.tsinghua.edu.cn/platform/manifest}
    #repo init --depth 1 -u "$TEST_URL" -b "$TEST_BRANCH" --repo-url=https://gerrit-google.tuna.tsinghua.edu.cn/git-repo


    ## Use default sync '-j' value embedded in manifest file to be polite
    #repo sync
    #prebuilts/misc/linux-x86/ccache/ccache -M 10G
    #cpus=$(grep ^processor /proc/cpuinfo | wc -l)
    #source build/envsetup.sh
    #lunch aosp_arm-eng
    #make -j $cpus

    #python
    #/bin/bash
    #./aaa
    . /usr/local/bin/aosp-script.sh 

else    #代码在docker外运行
    physical_path="$(cd $(dirname $(readlink -f $0)) && pwd -P)"
    
    . $physical_path/util

    if [ "$AOSP_VERSION" = "nougat" ]; then
        export AOSP_IMAGE="luxi78/aosp:re-7.0-nougat"
        ssh_config_file="ssh_config_n" 
    elif [ "$AOSP_VERSION" = "marshmallow" ]; then
        export AOSP_IMAGE="luxi78/aosp:re-6.0-marshmallow"
        ssh_config_file="ssh_config_m" 
    else
        msgerr The value of AOSP_VERSION must between marshmallow and nougat!
        exit 1 
    fi


    if [ -z ${DOCKER_RUN_SCRIPT+x} ]; then
        msgerr The value of DOCKER_RUN_SCRIPT must be specified!
        exit 1
    fi
    docker_run_file_path=$physical_path/script/$DOCKER_RUN_SCRIPT
    if [ ! -x $docker_run_file_path ]; then
        msgerr $docker_run_file_path wasn\'t found or no correct permission!
        exit 1
    fi


    args="bash run.sh docker"

    export AOSP_EXTRA_ARGS="-v $(readlink -f $0):/usr/local/bin/run.sh:ro \
        -v $docker_run_file_path:/usr/local/bin/aosp-script.sh:ro \
        -v $physical_path/config/$ssh_config_file:/root/.ssh/config:ro \
        -v $physical_path/config/gitconfig:/root/.gitconfig:ro"

    export AOSP_VOL=${AOSP_VOL:-"$(pwd)/aosp-root"}

    if [ ! -d "$AOSP_VOL" ]; then
        echo "Creating $AOSP_VOL"
        mkdir -p $AOSP_VOL 
    fi

    #
    # Try to invoke the aosp wrapper:
    #
    if [ -x "$physical_path/aosp" ]; then
        $physical_path/aosp $args
    else
        msgerr Unable to run the aosp binary!
        exit 1
    fi
fi
