#! /bin/bash

for file in $(pwd)/*.sh; do
    echo ${file}
    chmod 755 ${file}
done
