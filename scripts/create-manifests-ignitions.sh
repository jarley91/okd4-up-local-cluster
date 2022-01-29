source ./.env

mkdir -p ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads

curl -L -o ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads/openshift-install-linux.tar.gz ${OKD4_UTILS_DOWNLOAD_URL}/${OKD4_UTILS_VERSION}/openshift-install-linux-${OKD4_UTILS_VERSION}.tar.gz
curl -L -o ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads/openshift-client-linux.tar.gz ${OKD4_UTILS_DOWNLOAD_URL}/${OKD4_UTILS_VERSION}/openshift-client-linux-${OKD4_UTILS_VERSION}.tar.gz

mkdir ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads/openshift-install-linux
tar -xf ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads/openshift-install-linux.tar.gz -C ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads/openshift-install-linux
mkdir ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads/openshift-client-linux
tar -xf ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads/openshift-client-linux.tar.gz -C ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads/openshift-client-linux

mkdir ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/${PREFIX_NAME_CLUSTER_SERVER}-install-sources
cp ../utils/install-config.yaml ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/${PREFIX_NAME_CLUSTER_SERVER}-install-sources

alias openshift-install="${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/downloads/openshift-install-linux/openshift-install"
openshift-install create manifests --dir ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/${PREFIX_NAME_CLUSTER_SERVER}-install-sources
sed -i 's/true/false/g' ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/${PREFIX_NAME_CLUSTER_SERVER}-install-sources/manifests/cluster-scheduler-02-config.yml
openshift-install create ignition-configs --dir ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/${PREFIX_NAME_CLUSTER_SERVER}-install-sources

APACHE_WEB_DIR=/var/www/html/${PREFIX_NAME_CLUSTER_SERVER}
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_WEB_HAPROXY_SERVER} "mkdir ${APACHE_WEB_DIR}"
sshpass -f ../utils/password scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -r ${OKD4_WORK_DIR}/${PREFIX_NAME_CLUSTER_SERVER}-dir-install/${PREFIX_NAME_CLUSTER_SERVER}-install-sources/* root@${IP_WEB_HAPROXY_SERVER}:${APACHE_WEB_DIR}
sshpass -f ../utils/password ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${IP_WEB_HAPROXY_SERVER} "chown -R apache: /var/www/html/ && chmod -R 755 /var/www/html/"
