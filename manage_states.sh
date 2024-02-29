#!/bin/bash
#Put this script at dom0://srv/manage_states.sh
#included in git repo for completion, but will not be checked into dom0
#for obvious reasons

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source_vm="salt-dev"
tar_file="/home/user/personal_salt/states.tar.gz"

dry_run="false"

show_help() {
	cat << EOF
Usage: manage_states.sh [OPTION]... [COMMAND] ###Options MUST be before Command###
Copies salt file tar ball generated with package.sh to appropriate salt user directories

OPTIONS:
  --source-vm 	source qube to copy from, defaults to ${source_vm}
  --tar-hash 	hash of generated tar ball for verification, REQUIRED
  --tar-file 	location of tar file in --source-vm, defaults to: ${tar_file}
  --dry-run	prints action to be taken when deleting without doing anything
  --help	print this help message and exit

COMMANDS:
  get-hash 	computes hash of tar file at ${source_vm}://${tar_file}, mostly for ease of passing to this script
		during extraction, as copying isn't so simple
  clean         deletes all files not in predefined list to clean out the user environment
  clean-list	prints the exclusion list when calling clean
EOF
}

verify_tar() {
	computed_hash=$(qvm-run --pass-io ${source_vm} "sha256sum ${tar_file} | cut -f1 -d' '")
	if ! test "${computed_hash}" = "${tar_hash}"; then
		2>&1 echo "computed hash: ${computed_hash} doesn't match passed hash: ${tar_hash}, exiting"
		exit 1
	fi
}

extract_tar() {
	qvm-run --pass-io ${source_vm} "cat ${tar_file}" > /tmp/states.tar.gz
	tar -xzvf /tmp/states.tar.gz
}

print_clean_list() {
	exc_dirs="$(initialize_clean_arrs directories ${DIR})"
	if test "${#exc_dirs[@]}" -gt 0; then
		echo "excluded directories"
		for d in ${exc_dirs[@]}; do
			echo "${d}"
		done
	fi

	exc_files="$(initialize_clean_arrs files ${DIR})"
	if test "${#exc_clean_files[@]}" -gt 0; then
		echo "excluded files"
		for f in ${exc_files[@]}; do
			echo "${f}"
		done
	fi
}

safe_delete() {
	to_check="$1"
	dir="$2"
	dry_run=$3
	exc_dirs="$(initialize_clean_arrs directories ${dir})"
	if test -d "${to_check}"; then
		if ! [[ "${exc_dirs[@]}" =~ "${to_check}" ]]; then
			if test "${dry_run}" = "true"; then
				echo "removing directory: ${to_check}"
			else
				rm -rf "${to_check}"
			fi
			return
		fi
	#currently are only files or directories
	else
		for d in ${exc_dirs[@]}; do
			if [[ ${to_check} == ${d}* ]]; then
				return
			fi
		done
		exc_files="$(initialize_clean_arrs files ${dir})"
		if ! [[ "${exc_files[@]}" =~ "${to_check}" ]]; then
			if test "${dry_run}" = "true"; then
				echo "removing file: ${to_check}"
			else
				rm -f "${to_check}"
			fi
			return
		fi
	fi
}

export -f safe_delete

initialize_clean_arrs() {
	dir="$2"
	declare -a exc_clean_dirs
	exc_clean_dirs+=("${dir}/user_salt/files")
	exc_clean_dirs+=("${dir}/user_salt/locale")

	declare -a exc_clean_files

	tpe="$1"
	if test "${tpe}" = "files"; then
		echo ${exc_clean_files[@]}
	elif test "${tpe}" = "directories"; then
		echo ${exc_clean_dirs[@]}
	fi
}

export -f initialize_clean_arrs

clean() {
	find "${DIR}/user_salt" -mindepth 1 -exec bash -c 'safe_delete "$@"' bash {} ${DIR} ${dry_run} \; 2>/dev/null
}

while (( "$#" )); do
	case $1 in
		--source-vm)
			shift&&source_vm="$1"||die
			;;
		--tar-hash)
			shift&&tar_hash="$1"||die
			;;
		--tar-file)
			shift&&tar_file="$1"||die
			;;
		--dry-run)
			dry_run="true"||die
			;;
		--help)
			show_help
			exit 0
			;;
		get-hash)
			qvm-run --pass-io ${source_vm} "sha256sum ${tar_file} | cut -f1 -d' '"
			exit 0
			;;
		clean)
			clean
			exit 0
			;;
		clean-list)
			print_clean_list
			exit 0
			;;
		*)
			2>&1 echo "unrecognized option, exiting"
			show_help
			exit 1
			;;
	esac
	shift
done

verify_tar
extract_tar
