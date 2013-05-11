#!/bin/sh

set -e

create_mounts() {
    RELDIR=${1}
    WORLDDIR=${2}
    PORTSDIR=${3}

    mkdir -p ${RELDIR}/usr/ports ${RELDIR}/usr/src
    mount -t nullfs ${PORTSDIR} ${RELDIR}/usr/ports
    mount -t nullfs ${WORLDDIR} ${RELDIR}/usr/src
    mount -t devfs devfs ${RELDIR}/dev
}

delete_mounts() {
    RELDIR=${1}

    umount ${RELDIR}/dev/
    umount ${RELDIR}/usr/src
    umount ${RELDIR}/usr/ports
}

install_packages() {
    RELDIR=${1}; shift

    echo 'WITH_PKGNG=yes' >> ${RELDIR}/etc/make.conf
    for port in ${@}; do
        chroot ${RELDIR} make -C /usr/ports/${port} BATCH=1 install clean
    done
}

add_service() {
    RELDIR=${1}; shift

    echo "${1}_enable=\"YES\"" >> ${RELDIR}/etc/rc.conf
}

ACTION=${1}; shift

PORTSDIR=${1}
WORLDDIR=${2}
RELDIR=${3}

ports="www/apache22 \
      databases/mysql55-server"

create_mounts ${RELDIR} ${WORLDDIR} ${PORTSDIR}

install_packages ${RELDIR} ${ports}
add_service ${RELDIR} apache22
add_service ${RELDIR} mysql

delete_mounts ${RELDIR}
