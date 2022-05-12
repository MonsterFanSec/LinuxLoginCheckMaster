#!/bin/bash
#author:monster
#2022/5/12
echo "#########################################"
echo "#          linux-secure日志审查系统     #"
echo "#########################################"

loginSUser=$(cat /var/log/secure | grep "Accepted" | awk '{print $9;}' | uniq)
loginSUserTimes=$(cat /var/log/secure | grep "Accepted" | awk '{print $11;}' | wc -l)
loginSUserIP=$(cat /var/log/secure | grep "Accepted" | awk '{print $11;}' | uniq | sort | awk '{print $2,$1}')
loginNums=$(cat /var/log/secure | grep "Accepted" | wc -l)
FailedNums=$(cat /var/log/secure | grep "Failed" | wc -l)
BadIP=$(cat /var/log/secure | grep "Failed password for" | grep -o -E "([0-9]{1,3}\.){3}([0-9]){1,3}" | uniq -u | awk '{a[$1]++} END {for(i in a){print i,a[i]}}' | sort -n -r -k 2)
BadName=$(cat /var/log/secure | grep "Failed password for"| awk '{print $1,$2,$3,$9,$10,$11}' | uniq -u | awk '{a[$4]++} END {for(i in a){print i,a[i]}}' | sort -n -r -k 2)

cat /var/log/secure | grep "Accepted" | awk '{print $11;}' | uniq | sort | awk '{print $2,$1}'>login_success
cat /var/log/secure | grep "Failed password for" | grep -o -E "([0-9]{1,3}\.){3}([0-9]){1,3}" | uniq -c | awk '{a[$2]++} END {for(i in a){print i,a[i]}}' | sort -n -r -k 2 > badIP
cat /var/log/secure  | grep "Failed password\|Accepted password" > ssh_login_file 

echo "成功登入次数："$loginNums
echo "失败登入次数："$FailedNums
echo "成功登入的用户："$loginSUser"  登入次数："$loginSUserTimes" "
echo "成功登入IP："
for line in `cat login_success`  #for each line
do
	echo $line
done

for line1 in `cat login_success`
do
	if cat badIP |grep $line1 > /dev/null
	then
		echo "*** 警告：SSH服务已被破解 ***"
		inf=$(cat ssh_login_file | grep $line1 | grep "Accepted")
		user=$(echo $inf | awk -F" " '{print "ip:"$11 ":"$13"\t\t time: "$1,$2,$3"\t user:" $9 "\t\t state:Accepted"}')
		echo "详细信息   "$user
		echo "***************************"
		echo ""
	fi
done



echo "#########################################"
echo "#          尝试爆破ssh服务的恶意IP地址     #"
echo "#########################################"
echo "尝试爆破ssh的恶意IP："
time=0
for ip in $BadIP;do
	let time++
	if  [ $(($time%2)) -eq 1 ]
		then
			echo "恶意IP    "$ip | tr -d '\n'
	fi
	if  [ $(($time%2)) -eq 0 ]
		then
			echo "   攻击次数 "$ip
	fi
	if [ $time -eq 20 ]
		then
			break
	fi
done
echo "尝试破解的用户名："
time=0
for ip in $BadName;do
	let time++
	if  [ $(($time%2)) -eq 1 ]
		then
			echo "用户名    "$ip | tr -d '\n'
	fi
	if  [ $(($time%2)) -eq 0 ]
		then
			echo "   破解次数 "$ip
	fi
	if [ $time -eq 20 ]
		then
			break
	fi
done

rm -rf login_success
rm -rf badIP
rm -rf ssh_login_file



