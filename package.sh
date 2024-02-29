#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

declare -a pillars
pillars+=('user_pillar/top.sls')
pillars+=('user_pillar/global.sls')
pillars+=('user_pillar/go.sls')
pillars+=('user_pillar/dev_packages.sls')
pillars+=('user_pillar/vim.sls')
pillars+=('user_pillar/git.sls')

declare -a modules
modules+=('user_salt/_modules/taxonomy.py')

declare -a salt
salt+=('user_salt/top.sls')
salt+=('user_salt/go.sls')
salt+=('user_salt/dev_packages.sls')
salt+=('user_salt/vim.sls')
salt+=('user_salt/git.sls')
salt+=('user_salt/bash_it.sls')
salt+=('user_salt/less.sls')
salt+=('user_salt/docker/install.sls')
salt+=('user_salt/docker/rootless.sls')

declare -a formulas

hash_file=${DIR}/hashes.txt
tar_file=${DIR}/states.tar.gz

list_files() {
	echo "salt files:"
	for s in ${salt[@]}; do
		echo "	${DIR}/${s}"
	done

	echo "salt modules:"
	for m in ${modules[@]}; do
		echo "	${DIR}/${m}"
	done

	echo "pillar files:"
	for p in ${pillars[@]}; do
		echo "	${DIR}/${p}"
	done

	echo "formula files:"
	for f in ${formulas[@]}; do
		echo "	${DIR}/${p}"
	done
}

verify_hash_file() {
	temp_file=$(realpath ${1})	
	if ! test -f "${temp_file}"; then
		2>&1 echo "${temp_file} not found, exiting"
		exit 1
	fi
	if ! sha256sum -c ${temp_file}; then
		2>&1 echo "could not verify hashes, exiting"
		exit 1
	fi
	hash_file=${temp_file}
}

show_help() {
	cat << EOF
Usage: package.sh [OPTION]... [COMMAND]
Salt file management script

With no COMMAND, default command is list

OPTIONS:
  --hash-file 	hash file location, default: ${hash_file}, must exist when generating tar.
  --tar-file  	tar file location, default: ${tar_file}
  --help     	prints this help text and exits

COMMANDS, must be last in args:
  hashes 	generates hash file at --hash-file location
  tar    	generates tar ball of salt files at --tar-file location
  list    	lists all salt files to be generated(is hardcoded in this script)
  clean   	removes all generated files("${tar_file}", "${hash_file}")
EOF
}

get_file_list() {
	file_list=""
	for s in ${salt[@]}; do
		file_list+="${s} "
	done
	for m in ${modules[@]}; do
		file_list+="${m} "
	done
	for p in ${pillars[@]}; do
		file_list+="${p} "
	done
	for f in ${formulas[@]}; do
		file_list+="${f} "
	done
	echo -n "${file_list}"
}

generate_hashes() {
	temp_hashes=/tmp/salt_hashes.txt
	cd ${DIR}
	file_list="$(get_file_list)"
	sha256sum ${file_list} > ${temp_hashes}
	if ! test -f ${temp_hashes}; then
		2>&1 echo "failed generating hashes, exiting"
		exit 1
	fi
	mv ${temp_hashes} ${hash_file}
}

generate_tar() {
	verify_hash_file ${hash_file}
	file_list="$(get_file_list)"
	tar -czvf ${tar_file} ${file_list}
}

while (( "$#" )); do
	case $1 in
		--hash-file)
			shift&&hash_file="$1"||die
			;;
		--help)
			show_help
			exit 0
			;;
		--tar-file)
			shift&&tar_file="$1"||die
			;;
		hashes)
			generate_hashes
			exit 0
			;;
		tar)
			generate_tar
			exit 0
			;;
		list)
			list_files
			exit 0
			;;
		clean)
			rm -rf ${tar_file} ${hash_file}
			exit 0
			;;
		*)
			2>&1 echo "unrecognized command, exiting"
			show_help
			exit 1
			;;
	esac
	shift
done

list_files
exit 0
