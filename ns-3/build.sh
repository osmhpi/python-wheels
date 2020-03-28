#!/bin/sh -e

section() {
	echo "##[section]$@"
}

set_env() {
	echo "$1=$2"
	echo "::set-env name=$1::$2"
}

command() {
	echo "##[command]$@"
	"$@"
}

workdir() {
	if [ ! -d "$1" ]; then
		command mkdir -p "$1"
	fi
	command cd "$1"
}

run() {
	echo "##[group]$@"
	local code=0
	("$@") || code=$?
	echo "##[endgroup]"
	return $code
}

runsh() {
	echo "##[group]$1"
	local code=0
	(sh -c "$1") || code=$?
	echo "##[endgroup]"
	return $code
}

repo="$PWD"
base="$repo/ns-3"

section ---------------- Install ----------------
run apt-get update
run apt-get install -y --no-install-recommends \
	bzip2 \
	cmake \
	curl \
	g++ \
	git \
	libclang-dev \
	llvm-dev \
	make \
	patch \
	patchelf \
	python3-dev \
	python3-pip \
	python3-setuptools \
	python3-wheel \
	qt5-default \
	zip \
	&& true


run pip3 install \
	cxxfilt \
	git+https://github.com/felix-gohla/pygccxml@v1.9.2 \
	&& true

section ---------------- CastXML ----------------
workdir /opt/castxml
run git clone --branch v0.2.0 --depth 1 https://github.com/CastXML/CastXML.git .
run test "$(git rev-parse HEAD)" = 5ba47e3b67c4a9070e8404ed2db4d16c52e4267b
run cmake .
run make -j $(nproc)
run make install

export NS3_VERSION=3.30

# 3.30
ns3_download_sha1=b4d40bb9777ee644bdba50e3a2e221da85715b4e

section ---------------- download ----------------
workdir /opt/ns-3
run curl -L -o ../ns-3.tar.bz2 https://mgjm.de/ns-allinone-$NS3_VERSION.tar.bz2
runsh "echo '${ns3_download_sha1} ../ns-3.tar.bz2' | sha1sum -c"
run tar xj --strip-components 1 -f ../ns-3.tar.bz2


section ---------------- NetAnim ----------------
run patch -p 1 -i "$base/netanim_python_$NS3_VERSION.patch"

workdir netanim-*
run qmake NetAnim.pro
run make -j $(nproc)

section ---------------- ns-3 ----------------
workdir "/opt/ns-3/ns-$NS3_VERSION"
run ./waf configure
run ./waf --apiscan=netanim && \

workdir "/opt/ns-3"
run ./build.py -- install --destdir=/ns-3-build
run cp netanim-*/NetAnim /ns-3-build/usr/local/bin

section ---------------- python wheel ----------------
run cp "$base/__init__.py" /ns-3-build/usr/local/lib/python3/dist-packages/ns/
run cp -r "$base/ns" /opt/ns

workdir /opt/ns
run python3 setup.py bdist_wheel
run python3 -m wheel unpack -d patch "dist/ns-$NS3_VERSION-py3-none-any.whl"

ns3_patch="patch/ns-$NS3_VERSION"

for f in "$ns3_patch"/ns/*.so; do
	run patchelf --set-rpath '$ORIGIN/_/lib' "$f";
done

for f in "$ns3_patch"/ns/_/bin/*; do
	run patchelf --set-rpath '$ORIGIN/../lib' "$f";
	run chmod +x "$f";
done

run mkdir dist2
run python3 -m wheel pack -d dist2 "$ns3_patch"

asset_name="ns-$NS3_VERSION-py3.whl"
asset_path="$base/$asset_name"
run cp "dist2/ns-$NS3_VERSION-py3-none-any.whl" "$asset_path"

section ---------------- done ----------------
set_env ASSET_PATH "$asset_path"
set_env ASSET_NAME "$asset_name"
