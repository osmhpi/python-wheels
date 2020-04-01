section ---------------- install ----------------
run apt-get update
run apt-get install -y --no-install-recommends \
	git \
	ca-certificates \
	python3-setuptools \
	python3-wheel \
	&& true

section ---------------- build ----------------
workdir /opt/sumo
run git clone -b "v1_5_0" --depth 1 https://github.com/eclipse/sumo .

universal_wheels='traci sumolib'

for wheel in $universal_wheels; do
	workdir "/opt/$wheel"
	run python3 "../sumo/tools/build/setup-$wheel.py" bdist_wheel --universal
done

section ---------------- assets ----------------
for wheel in $universal_wheels; do
	asset "/opt/$wheel/dist"/*
done
