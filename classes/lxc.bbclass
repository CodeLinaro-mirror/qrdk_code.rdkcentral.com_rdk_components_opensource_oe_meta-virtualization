LXC_PACKAGES ?= "${PN}"
LXC_TEMPLATE ?= "lxc-xre"
LXC_NAME ?= "xre"
LXC_PATH = "/lxc"
python __anonymous() {
    if "container" in d.getVar('MACHINEOVERRIDES', True):
        d.appendVar("DEPENDS", " lxc-native")
}

lxc_postinst() {
rootDir="$D"
if ${@ 'true' if "container" in d.getVar('MACHINEOVERRIDES', True) else 'false' }; then
    mkdir -p ${rootDir}${LXC_PATH}
    echo "Executing :  lxc-create -t ${rootDir}/usr/share/lxc/templates/${LXC_TEMPLATE} -n ${LXC_NAME} -P ${rootDir}${LXC_PATH}"
    lxc-create -t ${rootDir}/usr/share/lxc/templates/${LXC_TEMPLATE} -n ${LXC_NAME} -P ${rootDir}${LXC_PATH}
    #Replace the rootfs path in config file  to  target runtime rootfs path
    if [ -f "${rootDir}${LXC_PATH}/${LXC_NAME}/config" ];then
        sed -i 's|'${rootDir}${LXC_PATH}'|'${LXC_PATH}'|g' "${rootDir}${LXC_PATH}/${LXC_NAME}/config"
    fi
    touch ${rootDir}${LXC_PATH}/${LXC_NAME}/${LXC_NAME}.log
fi
}

lxc_populate_packages[vardeps] += "lxc_postinst"
lxc_populate_packages[vardepsexclude] += "OVERRIDES"

python lxc_populate_packages() {
    for pkg in d.getVar('LXC_PACKAGES', True).split():
        postinst = d.getVar('pkg_postinst_%s' % pkg, True)
        if not postinst:
            postinst = '#!/bin/sh\n'
            postinst += d.getVar('lxc_postinst', True)
            d.setVar('pkg_postinst_%s' % pkg, postinst)
}

PACKAGESPLITFUNCS_prepend = "lxc_populate_packages "
FILES_${PN} += "/lxc/*"
