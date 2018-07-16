#!/bin/sh
#Author: jingchao
#Date: 20171214

. /etc/init.d/functions
#check current user
current_user=`whoami`
if [[ "$current_user" == "admin" ]];then
  action "user is admin" /bin/true
else
  action "please use admin to run this script !!!" /bin/false
  exit 1
fi

#yum list | grep expect > /dev/null
#if [ $? -ne 0 ];then
#	echo " expect is not included in your yum list, please check yum repo file in /etc/yum.repos.d/..."
#exit 1;
#fi

#rpm -qa | grep expect
#if [ $? -ne 0 ];then
#	echo " expect is not installed, installing... "
#	yum -y install expect 
#fi

base_path=$(cd "$(dirname "$0")";pwd)
host_ip=`awk '{print $2}' $base_path/nodes`;

for h in $host_ip
do
{
expect<<!!

spawn ssh admin@$h

expect {
	"*Are you sure you want to continue connecting*"
	{
		send "yes\n";
	}	 
}

expect {
	"*admin@$h's password*"
	{
		send "admin_password\n";
	}
}

expect "*$"
send "sudo passwd pop\r"

expect {
		"*New password:*"
		{	
			send "new_password\n";
		}

	}

expect {
		"*Retype new password:*"
		{
			send "new_password\n";
expect "*updated successfully*" {
					send "exit\n";
				}	 
		}

	}	

expect eof
!!
}
done
