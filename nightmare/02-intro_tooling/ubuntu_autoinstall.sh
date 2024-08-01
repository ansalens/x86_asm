#!/bin/bash

# update and upgrade
sudo apt update && sudo apt upgrade -y

# install cmd tools
sudo apt install curl vim

# install java and ghidra
sudo apt install openjdk-17-jdk
cd ~/Downloads/ && wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.1.2_build/ghidra_11.1.2_PUBLIC_20240709.zip -O ghidra.zip
sudo unzip ghidra.zip -d /opt

# install pwntools
sudo apt install python3-pip
python3 -m pip install --upgrade pwntools

# install gdb-gef
bash -c "$(curl -fsSL https://gef.blah.cat/sh)"
