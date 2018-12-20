#!/bin/bash

check_host() {
	[ "$1" = "$(hostname)" ]
}

check() {
	# usage: <check>
	# where check is
	# - if.<check-command>-<paramaters>

	case "$1" in 
		if.*)
			local check=${1#if.}

			# parse if condition
			case "$check" in
				true) true;;
				false) false;;

				host=*)
					local hostname=${check#host=}
					check_host $hostname
					;;

				*)
					echo "WARNING: unknown condition: $1" > /dev/stderr
					false
					;;

			esac
			return
			;;

		on.*)
			local hostname=${1#on.}
			check_host $hostname
			return
			;;
		*)
			break
	esac

	false
}


# check return code of command
# usage: <expected-command> <test-command>
#   <expected-command>: a command that exists with the expected code
#   <test-command>: this command should be tested
assert() {
	local expected=$1
	$expected
	local expected_result=$?
	shift

	# execute command
	$@ 
	local result=$?

	shift
	local args="$@"
	printf "checking %-40s    " "$args"
	printf 'expected: <%s> ' "$expected_result"
	printf 'returned <%s>' "$result"
	if [ $expected_result != $result ]; then
		printf '\n'
		echo "    ERROR"
	else
		printf ', OK\n'
	fi
}

# test the check command
unit_tests() {
	assert true  check if.true
	assert false  check if.false

	# host command
	assert true  check if.host=$(hostname)
	assert false check if.host=X$(hostname)
	assert true  check on.$(hostname)
	assert false check on.X$(hostname)
}


# command line arguments
while :; do
	case $1 in 
		--unit-tests)
			unit_tests
			;;
		-?*)
			printf "Unknown option: %s\n" "$1" >&2
			;;
		*)
			break
	esac
	shift
done




check on.$(hostname)
