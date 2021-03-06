#!/usr/bin/env bash
#
# This script cleans up orphaned configure sessions and releases disk (RAM) space
# https://community.ui.com/questions/Lingering-config-session/dffc0fef-1ced-4012-bea9-9f1313b06a76
VERSION='0.7.1'
ME=$(basename ${0})

if [ -n "$1" ]; then
    echo "${ME} Running in DEBUG mode"
    DEBUG="echo Dry run, this command would be executed: "
fi

# Make sure script runs as root
if [[ ${EUID} != 0 ]]
then
  echo "${ME} version ${VERSION} must be run as root, use: [sudo $(pwd)/${ME}]"
  exit 1
fi

if [[ $(ps -a | grep -e 'newgrp$') ]]
then
    echo "Configure session running - exit 'configure' before running this script!"
    exit 1
else
    for i in /opt/vyatta/config/tmp/new*
    do
        if [[ -d "${i}" ]]
        then
            echo "Unmounting ${i}..."
            ${DEBUG} umount "${i}"
            if [[ ${?} == 0 ]]
            then
                echo "${i} unmounted."
            else
                echo "Error: Couldn't unmount ${i}!"
            fi
            if [[ -d "${i}" ]]
            then
                echo "Removing directory ${i}..."
                ${DEBUG} rm -rf "${i}"
            fi
        fi
    done
    for i in /opt/vyatta/config/tmp/*
    do
        if [[ -d "${i}" ]]
        then
            echo "Removing directory ${i}..."
            ${DEBUG} rm -rf "${i}"
        fi
    done
    for i in /tmp/changes_only_*
    do
        if [[ -d "${i}" ]]
        then
            echo "Removing directory ${i}..."
            ${DEBUG} rm -rf "${i}"
        fi
    done
    for i in /tmp/config.new.boot.*
    do
        if [[ ! -s "${i}" ]]
        then
            echo "Removing file ${i}..."
            ${DEBUG} rm -rf "${i}"
        fi
    done
fi
