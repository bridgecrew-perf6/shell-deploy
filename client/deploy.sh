#!/bin/bash

basepath=$(dirname $0)
cmds="|commit|rollback|"
cmd=$1

isCmdEmpty=$(echo $cmds|grep "|$cmd|")
if [ -z "$isCmdEmpty" ] ; then
    echo "usage: $0 commit|rollback"
    exit 1
fi

program=some
user=root
hostname=192.168.1.2
password=this.is.password

src_path=/data1/htdocs/demo
# remote upload dir
dst_path=/data1/supervisor/demo/deploy/upload

src=$src_path/$program
dst=$dst_path/$program
deploy_script="/data1/supervisor/demo/deploy/deploy.sh $cmd"

if [ "$cmd" == "commit" ]; then
    echo "本地编译" 
    cd $src_path && CGO_ENABLED=0 GOOS=linux go build -o $src
    if [ $? -gt 0 ]; then
        echo "build fail."
        exit 1
    fi
fi

if [ "$cmd" == "commit" ]; then
    echo "推送远程"
    /usr/bin/expect <<-EOF
set timeout -1
spawn sftp $user@$hostname
expect "password:"
send "$password\r"
expect "sftp>"
send "put $src $dst\r"
expect "sftp>"
send "bye\r"
expect eof
EOF
fi

echo "远程部署"
/usr/bin/expect <<-EOF
set timeout -1
spawn ssh -t $user@$hostname "$deploy_script"
expect "password:"
send "$password\r"
expect eof
EOF

echo "done"
