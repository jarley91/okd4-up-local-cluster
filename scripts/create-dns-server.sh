source ./.env

# Create vm and config DNS server
VBoxManage import ${PATH_OVA_FILE_DNS} --vsys 0 --eula accept --vmname ${PREFIX_NAME_CLUSTER_SERVER}-dns --memory 1024 --cpus 4 --options keepallmacs

VBoxManage startvm ${PREFIX_NAME_CLUSTER_SERVER}-dns --type headless
sleep 30s

sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_TEMP} "sed -i 's/${IP_TEMP}/${IP_DNS_SERVER}/g' /etc/network/interfaces"
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_TEMP} "echo '      gateway ${IP_GATEWAY}' >> /etc/network/interfaces"
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_TEMP} "reboot"
sleep 30s
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_DNS_SERVER} "apt update && apt install -y bind9 bind9utils bind9-doc"
BIND_IP_V4='OPTIONS="-u bind -4"'
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_DNS_SERVER} "echo ${BIND_IP_V4} > /etc/default/bind9"
sshpass -f ../utils/password scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ../dns/named.conf.options ../dns/named.conf.local root@${IP_DNS_SERVER}:/etc/bind/
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_DNS_SERVER} "mkdir /etc/bind/zones"
sshpass -f ../utils/password scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ../dns/db.168.192 ../dns/db.okd4.local root@${IP_DNS_SERVER}:/etc/bind/zones/
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_DNS_SERVER} "reboot"