#!/bin/bash
IFS_old=$IFS      #将原IFS值保存，以便用完后恢复
IFS=$'\n'        #更改IFS值为$’\n’ ，注意，以回车做为分隔符，IFS必须为：$’\n’

cat /var/log/secure  | grep "Failed password\|Accepted password" > ssh_login_file 
for line in `cat ssh_login_file`  #for each line
do
	echo $line | grep "Accepted password">/dev/null
	if [ $? -eq 0 ];then
		echo $line| awk -F" " '{print "ip:"$11 ":"$13"\t\t time: "$1,$2,$3"\t user:" $9 "\t\t state:Accepted"}'
	else
		echo $line | grep "invalid user">/dev/null
		if [ $? -eq 0 ];then
			echo $line| awk -F" " '{print "ip:"$13 ":"$15 "\t\t time:"$1,$2,$3"\t user:" $11 "\t\t state:Failed"}'
		else
			echo $line| awk -F" " '{print "ip:"$11 ":"$13 "\t\t time:"$1,$2,$3"\t user:" $9 "\t\t state:Failed"}'
		fi
	fi
done
IFS=$IFS_old      #恢复原IFS值


