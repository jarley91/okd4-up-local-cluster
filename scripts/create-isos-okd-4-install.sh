source ./.env

mkdir ${OKD4_WORK_DIR}/syslinux

curl -o ${OKD4_WORK_DIR}/syslinux/syslinux-6.03.tar.xz https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.xz
tar -xf ${OKD4_WORK_DIR}/syslinux/syslinux-6.03.tar.xz -C ${OKD4_WORK_DIR}/syslinux/

mkdir -p ${OKD4_WORK_DIR}/fcos-iso-base/images
curl -o ${OKD4_WORK_DIR}/fcos-iso-base/images/vmlinuz https://builds.coreos.fedoraproject.org/prod/streams/${FCOS_STREAM}/builds/${FCOS_VER}/x86_64/fedora-coreos-${FCOS_VER}-live-kernel-x86_64
curl -o ${OKD4_WORK_DIR}/fcos-iso-base/images/initramfs.img https://builds.coreos.fedoraproject.org/prod/streams/${FCOS_STREAM}/builds/${FCOS_VER}/x86_64/fedora-coreos-${FCOS_VER}-live-initramfs.x86_64.img
curl -o ${OKD4_WORK_DIR}/fcos-iso-base/images/rootfs.img https://builds.coreos.fedoraproject.org/prod/streams/${FCOS_STREAM}/builds/${FCOS_VER}/x86_64/fedora-coreos-${FCOS_VER}-live-rootfs.x86_64.img

mkdir ${OKD4_WORK_DIR}/fcos-iso-base/isolinux
cp ${OKD4_WORK_DIR}/syslinux/syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32 ${OKD4_WORK_DIR}/fcos-iso-base/isolinux/ldlinux.c32
cp ${OKD4_WORK_DIR}/syslinux/syslinux-6.03/bios/core/isolinux.bin ${OKD4_WORK_DIR}/fcos-iso-base/isolinux/isolinux.bin
cp ${OKD4_WORK_DIR}/syslinux/syslinux-6.03/bios/com32/menu/vesamenu.c32 ${OKD4_WORK_DIR}/fcos-iso-base/isolinux/vesamenu.c32
cp ${OKD4_WORK_DIR}/syslinux/syslinux-6.03/bios/com32/lib/libcom32.c32 ${OKD4_WORK_DIR}/fcos-iso-base/isolinux/libcom32.c32
cp ${OKD4_WORK_DIR}/syslinux/syslinux-6.03/bios/com32/libutil/libutil.c32 ${OKD4_WORK_DIR}/fcos-iso-base/isolinux/libutil.c32

mkdir ${OKD4_WORK_DIR}/vbox-isos

# Bootstrap ISO
IP_SERVER=$(dig bootstrap.${DOMAIN_NAME} +short)

cat << EOF > ${OKD4_WORK_DIR}/fcos-iso-base/isolinux/isolinux.cfg
serial 0
default vesamenu.c32
timeout 1
menu clear
menu separator
label linux
  menu label ^Fedora CoreOS (Live)
  menu default
  kernel /images/vmlinuz
  append initrd=/images/initramfs.img,/images/rootfs.img ip=${IP_SERVER}::${IP_GATEWAY}:${IP_NETMASK}:bootstrap.${DOMAIN_NAME}::none nameserver=${IP_DNS_SERVER} coreos.inst=yes coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url=${OKD4_INSTALL_WEB_SERVER}/${PREFIX_NAME_CLUSTER_SERVER}/bootstrap.ign coreos.inst.platform_id=metal
menu separator
menu end
EOF

mkisofs -o ${OKD4_WORK_DIR}/vbox-isos/bootstrap.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -r ${OKD4_WORK_DIR}/fcos-iso-base/

# Masters ISOs
for server in master-1 master-2 master-3; do
  IP_SERVER=$(dig ${server}.${DOMAIN_NAME} +short)
  
  echo -e "serial 0\n\
default vesamenu.c32\n\
timeout 1\n\
menu clear\n\
menu separator\n\
label linux 
  menu label ^Fedora CoreOS (Live)\n\
  menu default\n\
  kernel /images/vmlinuz\n\
  append initrd=/images/initramfs.img,/images/rootfs.img ip=${IP_SERVER}::${IP_GATEWAY}:${IP_NETMASK}:${server}.${DOMAIN_NAME}::none nameserver=${IP_DNS_SERVER} coreos.inst=yes coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url=${OKD4_INSTALL_WEB_SERVER}/${PREFIX_NAME_CLUSTER_SERVER}/master.ign coreos.inst.platform_id=metal\n\
menu separator\n\
menu end" > ${OKD4_WORK_DIR}/fcos-iso-base/isolinux/isolinux.cfg

  mkisofs -o ${OKD4_WORK_DIR}/vbox-isos/${server}.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -r ${OKD4_WORK_DIR}/fcos-iso-base
done

# Infras ISOs
for server in infra-1 infra-2; do
  IP_SERVER=$(dig ${server}.${DOMAIN_NAME} +short)
  
  echo -e "serial 0\n\
default vesamenu.c32\n\
timeout 1\n\
menu clear\n\
menu separator\n\
label linux 
  menu label ^Fedora CoreOS (Live)\n\
  menu default\n\
  kernel /images/vmlinuz\n\
  append initrd=/images/initramfs.img,/images/rootfs.img ip=${IP_SERVER}::${IP_GATEWAY}:${IP_NETMASK}:${server}.${DOMAIN_NAME}::none nameserver=${IP_DNS_SERVER} coreos.inst=yes coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url=${OKD4_INSTALL_WEB_SERVER}/${PREFIX_NAME_CLUSTER_SERVER}/worker.ign coreos.inst.platform_id=metal\n\
menu separator\n\
menu end" > ${OKD4_WORK_DIR}/fcos-iso-base/isolinux/isolinux.cfg

  mkisofs -o ${OKD4_WORK_DIR}/vbox-isos/${server}.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -r ${OKD4_WORK_DIR}/fcos-iso-base
done

# Workers ISOs
for server in worker-1 worker-2 worker-3; do
  IP_SERVER=$(dig ${server}.${DOMAIN_NAME} +short)
  
  echo -e "serial 0\n\
default vesamenu.c32\n\
timeout 1\n\
menu clear\n\
menu separator\n\
label linux 
  menu label ^Fedora CoreOS (Live)\n\
  menu default\n\
  kernel /images/vmlinuz\n\
  append initrd=/images/initramfs.img,/images/rootfs.img ip=${IP_SERVER}::${IP_GATEWAY}:${IP_NETMASK}:${server}.${DOMAIN_NAME}::none nameserver=${IP_DNS_SERVER} coreos.inst=yes coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url=${OKD4_INSTALL_WEB_SERVER}/${PREFIX_NAME_CLUSTER_SERVER}/worker.ign coreos.inst.platform_id=metal\n\
menu separator\n\
menu end" > ${OKD4_WORK_DIR}/fcos-iso-base/isolinux/isolinux.cfg

  mkisofs -o ${OKD4_WORK_DIR}/vbox-isos/${server}.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -r ${OKD4_WORK_DIR}/fcos-iso-base
done