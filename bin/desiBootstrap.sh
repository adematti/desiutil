#!/bin/bash
#
# $Id$
#
function usage() {
    local execName=$(basename $0)
    (
    echo "${execName} [-h] [-m MODULESHOME] [-p PYTHON] [-t] [-U USER] [-v]"
    echo ""
    echo "Install desiUtil on a bare system."
    echo ""
    echo "    -h = Print this message and exit."
    echo "    -m = Look for the Modules install in MODULESHOME."
    echo "    -p = Use the Python executable PYTHON (e.g. /opt/local/bin/python2.7)."
    echo "    -t = Test mode.  Do not make any changes.  Implies -v."
    echo "    -U = Set the svn username to USER (default '${USER}')."
    echo "    -v = Verbose mode. Print lots of extra information."
    ) >&2
}
#
# Get options
#
test=''
verbose=''
modules=''
u=${USER}
py=''
while getopts hm:p:tU:v argname; do
    case ${argname} in
        h) usage; exit 0 ;;
        m) modules=${OPTARG} ;;
        p) py=${OPTARG} ;;
        t) test='-t' ;;
        U) u=${OPTARG} ;;
        v) verbose='-v' ;;
        *) usage; exit 1 ;;
    esac
done
shift $((OPTIND-1))
#
# Install
#
if [[ -z "${DESI_PRODUCT_ROOT}" && -z "${NERSC_HOST}" ]]; then
    echo "You haven't set the DESI_PRODUCT_ROOT environment variable."
    echo "I'm not going to try to guess where you want to install things."
    exit 1
fi
if [[ -n "${modules}" ]]; then
    export MODULESHOME=${modules}
fi
if [[ -z "${MODULESHOME}" ]]; then
    echo "You do not appear to have Modules installed."
    exit 1
fi
svn --username ${u} export https://desi.lbl.gov/svn/code/tools/desiUtil/trunk desiUtil-trunk
export DESIUTIL_DIR=$(pwd)/desiUtil-trunk
export PATH=${DESIUTIL_DIR}/bin:${PATH}
if [[ -z "${PYTHONPATH}" ]]; then
    export PYTHONPATH=${DESIUTIL_DIR}/py
else
    export PYTHONPATH=${DESIUTIL_DIR}/py:${PYTHONPATH}
fi
if [[ -z "${py}" ]]; then
    desiInstall -b -U ${u} ${test} ${verbose}
else
    ${py} ${DESIUTIL_DIR}/bin/desiInstall -b -U ${u} -p ${py} ${test} ${verbose}
fi
/bin/rm -rf desiUtil-trunk
