#!/bin/bash
#
# Copyright (c) 2017-2018 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

# This script will execute the Kata Containers Test Suite. 

set -e

cidir=$(dirname "$0")
source "${cidir}/lib.sh"

export RUNTIME="kata-runtime"

export CI_JOB="${CI_JOB:-default}"

case "${CI_JOB}" in
	"CRI_CONTAINERD_K8S")
		echo "INFO: Containerd checks"
		sudo -E PATH="$PATH" bash -c "make cri-containerd"
		sudo -E PATH="$PATH" CRI_RUNTIME="containerd" bash -c "make kubernetes"
		;;
	"FIRECRACKER")
		echo "INFO: Running docker integration tests"
		sudo -E PATH="$PATH" bash -c "make docker"
		echo "INFO: Running soak test"
		sudo -E PATH="$PATH" bash -c "make docker-stability"
		echo "INFO: Running oci call test"
		sudo -E PATH="$PATH" bash -c "make oci"
		echo "INFO: Running networking tests"
		sudo -E PATH="$PATH" bash -c "make network"
		;;
	*)
		sudo journalctl -t kata-runtime -t kata-proxy -f &
		docker run -i --runtime=kata-runtime busybox true
esac
