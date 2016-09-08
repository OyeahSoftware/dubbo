#/bin/bash

if [ "${1}" = "" ]; then
   echo "第一个参数不能为空，请输入执行的权重设置动作，如：full zero"
   exit 1
fi

if [ "${2}" = "" ]; then
   echo "第二个参数不能为空，请输入监控的应用实例的dubbo地址，如：192.168.40.204:20881"
   exit 1
fi

#获取要执行的权重设置动作
admin_action=${1}
#设置dubbo-admin应用的访问用户名
admin_user="root"
#设置dubbo-admin应用的访问密码
admin_password="root"

#设置dubbo-admin应用的地址
admin_web="http://192.168.40.204:9001/"
#设置监控的应用实例的dubbo地址,ip:port
app_address=${2}
#设置监控的应用实例的dubbo地址,ip:port
prefix_url="${admin_web}governance/addresses/${app_address}/providers"

#列出观测的应用实例中的所有provider的id,以+拼接返回
function providers_list(){
	curl -u ${admin_user}:${admin_password} ${prefix_url}/list --silent
}

#将传入的所有provider的id的权重设置为0
function providers_zero(){
	if curl -s -I --connect-timeout 5 --max-time 10 -u ${admin_user}:${admin_password} ${prefix_url}/${1}/zero | grep -q '200 OK'; then
		echo "设置 ${app_address} 的权重为0 OK"
	else
		echo "设置 ${app_address} 的权重为0 FAULT"
    fi
}

#将传入的所有provider的id的权重设置为100
function providers_full(){
	if curl -s -I --connect-timeout 5 --max-time 10 -u ${admin_user}:${admin_password} ${prefix_url}/${1}/full | grep -q '200 OK'; then
		echo "设置 ${app_address} 的权重为100 OK"
	else
		echo "设置 ${app_address} 的权重为100 FAULT"
    fi
}

#获取当前监控的应用实例下面的所有provider的id
providers_ids=$(providers_list)

if [ ${admin_action} = "full" ]; then
	providers_full ${providers_ids}
elif [ ${admin_action} = "zero" ]; then
	providers_zero ${providers_ids}
else
	echo "非法的权重设置动作"
fi

exit 0
