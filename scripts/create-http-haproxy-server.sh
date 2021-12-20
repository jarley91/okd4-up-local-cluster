source ./.env

# Create vm and config HTTP(Apache) y Balancer(HAproxy) server
VBoxManage import ${PATH_OVA_FILE_WEB_HAPROXY} --vsys 0 --eula accept --vmname ${PREFIX_NAME_CLUSTER_SERVER}-http-balancer --memory 2048 --cpus 4 --options keepallmacs

VBoxManage startvm ${PREFIX_NAME_CLUSTER_SERVER}-http-balancer --type headless
sleep 30s

sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_TEMP} "sed -i 's/${IP_TEMP}/${IP_WEB_HAPROXY_SERVER}/g' /etc/sysconfig/network-scripts/ifcfg-enp0s3"
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_TEMP} "sed -i 's/0.0.0.1/${IP_GATEWAY}/g' /etc/sysconfig/network-scripts/ifcfg-enp0s3"
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_TEMP} "sed -i 's/0.0.0.2/${IP_DNS_SERVER}/g' /etc/sysconfig/network-scripts/ifcfg-enp0s3"
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_TEMP} "reboot"
sleep 30s
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_WEB_HAPROXY_SERVER} "yum update && yum install -y haproxy httpd"
sshpass -f ../utils/password scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ../haproxy/haproxy.cfg root@${IP_WEB_HAPROXY_SERVER}:/etc/haproxy/
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_WEB_HAPROXY_SERVER} "setsebool -P haproxy_connect_any 1 && systemctl enable haproxy && systemctl start haproxy"
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_WEB_HAPROXY_SERVER} "firewall-cmd --permanent  --add-port=80/tcp --add-port=443/tcp --add-port=6443/tcp --add-port=22623/tcp && firewall-cmd --reload"
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_WEB_HAPROXY_SERVER} "sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf"
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_WEB_HAPROXY_SERVER} "setsebool -P httpd_read_user_content 1 && systemctl enable httpd && systemctl start httpd && firewall-cmd --permanent --add-port=8080/tcp && firewall-cmd --reload"