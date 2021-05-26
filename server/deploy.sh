#!/usr/bin/env bash

basepath=$(dirname $0)
cmds="|commit|rollback|"
cmd=$1

isCmdEmpty=$(echo $cmds|grep "|$cmd|")
if [ -z "$isCmdEmpty" ] ; then
    echo "usage: $0 commit|rollback"
    exit 1
fi

if [ ! -d $basepath/archive ]; then
    mkdir $basepath/archive
fi

if [ ! -d $basepath/upload ]; then
    mkdir $basepath/upload
fi

# 处理上传文件，编排入档
if [ "$cmd" == "commit" ]; then
    program=$(ls $basepath/upload/)
    program_file=$basepath/upload/$program
    if [ ! -d "$program_file" -a -e "$program_file" ]; then
        new_version=$[$(ls $basepath/archive/|sort -r|head -n 1|cut -d . -f 2) + 1]
        md5sum=$(md5sum $program_file|cut -d " " -f 1)
        if [ ! -z "$md5sum" ]; then
            mv $program_file $basepath/archive/$program.$new_version.$md5sum
        fi
    fi
fi

# 部署最新版本
if [ "$cmd" == "commit" ]; then
    software=$(ls $basepath/archive/|sort -r|head -n 1)
fi

# 回滚
if [ "$cmd" == "rollback" ]; then
    software=$(ls $basepath/archive/|sort|tail -n 2|head -n 1)
fi

if [ -z "$software" ]; then
    dist=$basepath/../kn
    ln -sf deploy/archive/$software $dist && \
        cd /docker/ && docker-compose restart kn && cd -
else
    echo "deploy fail."
fi

echo done
