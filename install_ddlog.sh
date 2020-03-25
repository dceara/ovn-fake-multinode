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

cd /bin/

curl https://sh.rustup.rs -sSf -o rust.sh
chmod +x rust.sh
./rust.sh -y
. $HOME/.cargo/env
rustup component add rustfmt
rustup component add clippy

. $HOME/.cargo/env

curl -L https://github.com/vmware/differential-datalog/releases/download/v0.15.3/ddlog-v0.15.3-20200323050632-linux.tar.gz -o ddlog-v0.15.3-20200323050632-linux.tar.gz
tar xfz ddlog-v0.15.3-20200323050632-linux.tar.gz
mv ddlog/ ddlog-dir
cp ddlog-dir/bin/* .

