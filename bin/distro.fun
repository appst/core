:<<\_c
. $PICASSO/core/bin/distro.fun
_c


case $OS in

ubuntu)

function _distro_get_version() {
DISTRO_MAJOR_VERSION=$(echo $DISTRO_RELEASE | /usr/bin/cut -d. -f1)
DISTRO_MINOR_VERSION=$(echo $DISTRO_RELEASE | /usr/bin/cut -d. -f2)
DISTRO_REVISION=$(echo $DISTRO_RELEASE | /usr/bin/cut -d. -f3)
}

function _distro_get_sha256_checksum() {
_distro_get_version
release="${DISTRO_MAJOR_VERSION}.${DISTRO_MINOR_VERSION}"
[[ -n "$DISTRO_REVISION" ]] && release+=".${DISTRO_REVISION}"
BASEBOX_REPO=$PWWW_DIR/repo/com/ubuntu
cat $BASEBOX_REPO/${DISTRO_MAJOR_VERSION}.$DISTRO_MINOR_VERSION/SHA256SUMS | grep ${DISTRO_NAME}-${release}-${DISTRO_TYPE}-${DISTRO_ARCH}.iso | /usr/bin/cut -d' ' -f1
}

;;

esac

:<<\_x
DISTRO_NAME=ubuntu
DISTRO_RELEASE=18.04.4
DISTRO_TYPE=server
DISTRO_ARCH=amd64

BASEBOX_REPO=$PWWW_DIR/repo/com/ubuntu

OS=ubuntu . $PICASSO/core/bin/distro.fun; _distro_get_version  # <- $DISTRO_RELEASE -> $DISTRO_MAJOR_VERSION, $DISTRO_MINOR_VERSION, $DISTRO_REVISION
DISTRO_SHA256_CHECKSUM=$(_distro_get_sha256_checksum)

iso_name=${DISTRO_NAME}-${DISTRO_RELEASE}-${DISTRO_TYPE}-${DISTRO_ARCH}

REPO_ISO="$PWWW_DIR/repo/com/ubuntu/${DISTRO_MAJOR_VERSION}.${DISTRO_MINOR_VERSION}/${iso_name}.iso"
REPO_ISO_URL="file://$(convertpath -m $REPO_ISO)"
_x
