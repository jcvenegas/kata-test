#!/bin/bash
#
# Copyright (c) 2017-2018 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

# This script will execute the Kata Containers Test Suite.

set -e
set -x
export DEBUG=true

cidir=$(dirname "$0")
source "${cidir}/lib.sh"

export RUNTIME="kata-runtime"

export CI_JOB="${CI_JOB:-default}"

case "${CI_JOB}" in
	"CRI_CONTAINERD_K8S")
		echo "INFO: Containerd checks"
		sudo -E PATH="$PATH" bash -c "make cri-containerd"
		sudo -E PATH="$PATH" CRI_RUNTIME="containerd" bash -c "make kubernetes"

		# Make sure the feature works with K8s + containerd
		"${cidir}/toggle_sandbox_cgroup_only.sh" true
		sudo -E PATH="$PATH" bash -c "make cri-containerd"
		"${cidir}/toggle_sandbox_cgroup_only.sh" true
		sudo -E PATH="$PATH" CRI_RUNTIME="containerd" bash -c "make kubernetes"
		# remove config created by toggle_sandbox_cgroup_only.sh
		"${cidir}/toggle_sandbox_cgroup_only.sh" false
		sudo rm -f "/etc/kata-containers/configuration.toml"
		;;
	"FIRECRACKER" | "CLOUD-HYPERVISOR")
		echo "INFO: Running docker integration tests"
		sudo -E PATH="$PATH" bash -c "make docker"
		echo "INFO: Running soak test"
		sudo -E PATH="$PATH" bash -c "make docker-stability"
		echo "INFO: Running oci call test"
		sudo -E PATH="$PATH" bash -c "make oci"
		echo "INFO: Running networking tests"
		sudo -E PATH="$PATH" bash -c "make network"
		echo "INFO: Running crio tests"
		sudo -E PATH="$PATH" bash -c "make crio"
		;;
	*)
		echo "INFO: Running checks"
		sudo -E PATH="$PATH" bash -c "make check"

		echo "INFO: Running functional and integration tests ($PWD)"
		sudo -E PATH="$PATH" bash -c "make test"
		;;
esac
