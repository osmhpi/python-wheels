# Python Wheels for different simulators

This repository contains python wheels for the simulators used by [cohydra](https://github.com/osmhpi/cohydra).

## Installation

It so far tested with **Python 3.7**.
Use the following command to install *ns-3.33* from the wheel:

```
sudo pip3 install "https://github.com/osmhpi/python-wheels/releases/latest/download/ns-3.33-cp37-cp37m-linux_x86_64.whl"
```

## Troubleshooting

### Problems with nacl dependency
After installing the wheel and trying to run cohydra with the dependencies from the wheel, it can happen that `nacl` does not work anymore.
During the execution of cohydra it tried to use `nacl._sodium` as part of the dependency `paramiko`, but didn't found it anymore.

To solve this problem, reinstall `nacl`:

```
sudo pip3 uninstall pynacl
sudo pip3 install pynacl
```

If you are facing issues during the uninstall of `pynacl` (pip does not want to uninstall the package), run:

```
sudo apt remove python3-pip
```

and reinstall it like it is described here: [https://pip.pypa.io/en/stable/installing/](https://pip.pypa.io/en/stable/installing/)

### I have python 3.6.x or older

Run:

```
sudo apt install python3.7
```

to install python 3.7.
And follow these instructions afterwards: [https://jcutrer.com/linux/upgrade-python37-ubuntu1810](https://jcutrer.com/linux/upgrade-python37-ubuntu1810)
