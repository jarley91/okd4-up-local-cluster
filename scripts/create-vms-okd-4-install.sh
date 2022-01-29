source ./.env

DEFAULT_DIR_VM_VBOX="Default machine folder:"
DEFAULT_DIR_VM_VBOX_VALUE=$(VBoxManage list systemproperties | grep "${DEFAULT_DIR_VM_VBOX}")
DEFAULT_DIR_VM_VBOX=$(echo ${DEFAULT_DIR_VM_VBOX_VALUE//$DEFAULT_DIR_VM_VBOX/" "})

NAME_VM=${PREFIX_NAME_CLUSTER_SERVER}-bootstrap
vboxmanage createvm --name "${NAME_VM}" --ostype Fedora_64 --register
vboxmanage modifyvm "${NAME_VM}" --memory 6144 --cpus 4 --vram 20 --graphicscontroller vmsvga --rtcuseutc on
vboxmanage storagectl "${NAME_VM}" --name SATA --add sata --controller IntelAhci --portcount 30 --bootable on
vboxmanage createmedium --filename "${DEFAULT_DIR_VM_VBOX}/${NAME_VM}/${NAME_VM}" --size 131072 --format VDI
vboxmanage storageattach "${NAME_VM}" --storagectl SATA --type hdd --port 0 --device 0 --medium "${DEFAULT_DIR_VM_VBOX}/${NAME_VM}/${NAME_VM}.vdi"
vboxmanage storagectl "${NAME_VM}" --name IDE --add ide --controller PIIX4 --hostiocache on --portcount 2 --bootable on
vboxmanage storageattach "${NAME_VM}" --storagectl IDE --type dvddrive --port 1 --device 0 --medium "${OKD4_WORK_DIR}/vbox-isos/bootstrap.iso"
VBoxManage modifyvm "${NAME_VM}" --nic1 bridged --nictype1 82540EM --bridgeadapter1 ${HOST_NI_FOR_BRIDGE}

for server in master-1 master-2 master-3; do
  NAME_VM=${PREFIX_NAME_CLUSTER_SERVER}-${server}
  vboxmanage createvm --name "${NAME_VM}" --ostype Fedora_64 --register
  vboxmanage modifyvm "${NAME_VM}" --memory 12288 --cpus 4 --vram 20 --graphicscontroller vmsvga --rtcuseutc on
  vboxmanage storagectl "${NAME_VM}" --name SATA --add sata --controller IntelAhci --portcount 30 --bootable on
  vboxmanage createmedium --filename "${DEFAULT_DIR_VM_VBOX}/${NAME_VM}/${NAME_VM}" --size 131072 --format VDI
  vboxmanage storageattach "${NAME_VM}" --storagectl SATA --type hdd --port 0 --device 0 --medium "${DEFAULT_DIR_VM_VBOX}/${NAME_VM}/${NAME_VM}.vdi"
  vboxmanage storagectl "${NAME_VM}" --name IDE --add ide --controller PIIX4 --hostiocache on --portcount 2 --bootable on
  vboxmanage storageattach "${NAME_VM}" --storagectl IDE --type dvddrive --port 1 --device 0 --medium "${OKD4_WORK_DIR}/vbox-isos/${server}.iso"
  VBoxManage modifyvm "${NAME_VM}" --nic1 bridged --nictype1 82540EM --bridgeadapter1 ${HOST_NI_FOR_BRIDGE}
done

for server in infra-1 infra-2; do
  NAME_VM=${PREFIX_NAME_CLUSTER_SERVER}-${server}
  vboxmanage createvm --name "${NAME_VM}" --ostype Fedora_64 --register
  vboxmanage modifyvm "${NAME_VM}" --memory 6144 --cpus 4 --vram 20 --graphicscontroller vmsvga --rtcuseutc on
  vboxmanage storagectl "${NAME_VM}" --name SATA --add sata --controller IntelAhci --portcount 30 --bootable on
  vboxmanage createmedium --filename "${DEFAULT_DIR_VM_VBOX}/${NAME_VM}/${NAME_VM}" --size 131072 --format VDI
  vboxmanage storageattach "${NAME_VM}" --storagectl SATA --type hdd --port 0 --device 0 --medium "${DEFAULT_DIR_VM_VBOX}/${NAME_VM}/${NAME_VM}.vdi"
  vboxmanage storagectl "${NAME_VM}" --name IDE --add ide --controller PIIX4 --hostiocache on --portcount 2 --bootable on
  vboxmanage storageattach "${NAME_VM}" --storagectl IDE --type dvddrive --port 1 --device 0 --medium "${OKD4_WORK_DIR}/vbox-isos/${server}.iso"
  VBoxManage modifyvm "${NAME_VM}" --nic1 bridged --nictype1 82540EM --bridgeadapter1 ${HOST_NI_FOR_BRIDGE}
done

for server in worker-1 worker-2 worker-3; do
  NAME_VM=${PREFIX_NAME_CLUSTER_SERVER}-${server}
  vboxmanage createvm --name "${NAME_VM}" --ostype Fedora_64 --register
  vboxmanage modifyvm "${NAME_VM}" --memory 6144 --cpus 4 --vram 20 --graphicscontroller vmsvga --rtcuseutc on
  vboxmanage storagectl "${NAME_VM}" --name SATA --add sata --controller IntelAhci --portcount 30 --bootable on
  vboxmanage createmedium --filename "${DEFAULT_DIR_VM_VBOX}/${NAME_VM}/${NAME_VM}" --size 131072 --format VDI
  vboxmanage storageattach "${NAME_VM}" --storagectl SATA --type hdd --port 0 --device 0 --medium "${DEFAULT_DIR_VM_VBOX}/${NAME_VM}/${NAME_VM}.vdi"
  vboxmanage storagectl "${NAME_VM}" --name IDE --add ide --controller PIIX4 --hostiocache on --portcount 2 --bootable on
  vboxmanage storageattach "${NAME_VM}" --storagectl IDE --type dvddrive --port 1 --device 0 --medium "${OKD4_WORK_DIR}/vbox-isos/${server}.iso"
  VBoxManage modifyvm "${NAME_VM}" --nic1 bridged --nictype1 82540EM --bridgeadapter1 ${HOST_NI_FOR_BRIDGE}
done