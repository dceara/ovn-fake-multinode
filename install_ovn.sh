#!/bin/sh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o xtrace
set -o errexit

use_ovn_rpm=$1
extra_optimize=$2

. $HOME/.cargo/env

if [ "$extra_optimize" = "yes" ]; then
    cflags='-g -march=native -O3 -fno-omit-frame-pointer'
else
    cflags='-g -O2 -fno-omit-frame-pointer'
fi

if [ "$use_ovn_rpm" = "yes" ]; then
    ls ovn*.rpm > /dev/null || exit 1
    dnf install -y /*.rpm
else
    # get ovs source always from master as its needed as dependency
    cd /ovs
    # build and install
    ./boot.sh
    ./configure --localstatedir="/var" --sysconfdir="/etc" --prefix="/usr" \
    --enable-ssl --disable-libcapng CFLAGS="${cflags}"
    make -j$(($(nproc) + 1)) V=0
    make install

    cd /ovn
    # build and install
    ./boot.sh
    ./configure --localstatedir="/var" --sysconfdir="/etc" --prefix="/usr" \
    --enable-ssl --with-ovs-source=/ovs/ --with-ovs-build=/ovs/ \
    --with-ddlog=/bin/ddlog-dir/lib/
    CFLAGS="${cflags}"
    make V=0
    make install
fi

# Generate SSL certificates.
cd /
mkdir -p /opt/ovn
OVS_PKI="ovs-pki --dir=/opt/ovn/pki"
$OVS_PKI init
pushd /opt/ovn
$OVS_PKI req+sign ovn switch
popd

# remove unused packages to make the container light weight.
for i in $(package-cleanup --leaves --all);
    do dnf remove -y $i
done
dnf autoremove -y

dnf -y remove automake make gcc autoconf openssl-devel libtool ||:

rm -rf /ovs /ovn
