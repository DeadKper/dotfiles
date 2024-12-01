#!/usr/bin/env bash

main() {
	source <(__parser_main "$@")
	test -z "$__PARSER_ERROR" || exit "$__PARSER_ERROR"
}

# PARSER SECTION
__parser_main() {
	read -t 0
	if test "$?" = 0; then
		readarray -t __parser_cli_args < <(cat -)
	else
		echo __PARSER_ERROR=1
		cat <<EOF >&2
parser error: could not read data from stdin

parser example usage:
#/bin/bash

# sections are ';' separated, last section can contain ; in it's text without problem, the sections are:
#   1) flags: this are the flags to use in the program, can be like '-h', '--help' or '-h --help'
#   2) type: can be bool, count, append or store
#     - bool: will be set to 'true' if flag is given, default if no type is given
#     - append: will append all instances of the called flag to the output
#     - count: will be set to the number of occurences this flag has
#     - store: store 1 argument
#     - store?: store 0 or 1 argument
#     - store*: store 0 or more arguments
#     - store+: store 1 or more arguments
#     - store\d+: store N arguments
#     - store\d+,: store N or more arguments
#     - store,\d+: store up to N arguments
#     - store\d+,\d+: store from N1 to N2 arguments
#   3) name: variable name in which to store the parsed output, will be auto-detected if possible
#   4) metavar: name of the meta variable to show in the help text, will be ARG if none is given
#   5) help: description of the argument to print in the help text
cli_args+=("-h --help;;;;print help text and exit")
cli_args+=("-V --version;;;;print version number and exit")

unset PARSER_HYPHEN_VALUES # the variable PARSER_HYPHEN_VALUES can be set to any non empty value to allow hypen values
unset PARSER_OVERRIDE_FLAGS # decide wheter keep first flag value (first), keep last value (last), or fail if flag is repeated (anything else)
source <(cat ./optsparser.bash | sed -zE 's/.*\n(# PARSER SECTION\n)/\1/;s/(\n# END OF PARSER\n).*/\1/')
source <(printf '%s\n' "\${cli_args[@]}" | __parser_main "\$@")
test -z "\$__PARSER_ERROR" || exit "\$__PARSER_ERROR"

if test -n "\$VERSION"; then
	echo "\$(basename "\$0") version 0.1"
	exit
fi
if test -n "\$HELP"; then
	__parser_print_help "\${cli_args[@]}"
	exit
fi
EOF
		return 1
	fi
	readarray -t __parser_cli_args < <(__parser_make_args "${__parser_cli_args[@]}")
	test "${#__parser_cli_args[@]}" -gt 0 || { echo __PARSER_ERROR=1; return 1; }
	printf '%s\n' "${__parser_cli_args[@]}" | __parser_parse_args "$@"
}

__parser_var_parse() {
	sed 's/;/\n/;s/;/\n/;s/;/\n/;s/;/\n/'
}

__parser_make_args() {
	local __parser_args=()
	local __parser_regex='^-\w$|^--[a-z0-9](-?[a-z0-9]+)+$'
	for __parser_arg in "$@"; do
		readarray -t __parser_data < <(__parser_var_parse <<< "$__parser_arg")
		for __parser_flag in ${__parser_data[0]}; do
			if ! grep -qE "$__parser_regex" <<< "$__parser_flag"; then
				echo parser error: invalid flag "'$__parser_flag'" it needs to follow the regex "'$__parser_regex'" >&2
				return 1
			fi
		done
		if test -z "${__parser_data[1]}"; then
			__parser_data[1]=bool
		fi
		if test "${__parser_data[1]}" = store; then
			__parser_data[1]=store1,1
		fi
		if test -z "${__parser_data[2]}"; then
			for __parser_flag in ${__parser_data[0]}; do
				if grep -qE '^--' <<< "$__parser_flag"; then
					__parser_data[2]="$(echo "$__parser_flag" | sed 's/^--//')"
				fi
			done
			if test -z "${__parser_data[2]}" -a -n "${__parser_data[3]}"; then
				__parser_data[2]="${__parser_data[3]}"
			fi
			if test -z "${__parser_data[2]}"; then
				echo parser error: parser flag "'${__parser_flag[@]}'" only has short option and no var name was specified >&2
				return 1
			fi
		fi
		__parser_data[2]="$(tr a-z- A-Z_ <<< "${__parser_data[2]}")"
		if grep -qE '^[0-9]' <<< "${__parser_data[2]}"; then
			echo parser error: var name cannot start with a number for flags "'${__parser_data[0]}'" >&2
			return 1
		fi
		if ! grep -qiE '^[a-z0-9]{3,}' <<< "${__parser_data[2]}"; then
			echo parser error: var name needs to be at least 3 characters long \(before underscores\) for flags "'${__parser_data[0]}'" >&2
			return 1
		fi
		if test -z "${__parser_data[3]}"; then
			__parser_data[3]=ARG
		else
			__parser_data[3]="$(tr a-z- A-Z_ <<< "${__parser_data[3]}")"
		fi
		case "${__parser_data[1]}" in
			bool|append|count)
				;;
			'store?')
				__parser_data[1]="store0,1"
				;;
			'store*')
				__parser_data[1]="store0,-1"
				;;
			'store+')
				__parser_data[1]="store1,-1"
				;;
			store*)
				if ! grep -qE '^store([0-9]+,?|[0-9]*,[0-9]+)$' <<< "${__parser_data[1]}"; then
					echo parser error: unrecognized flag type "'${__parser_data[1]}'" >&2
					return 1
				elif grep -qE '^store[0-9]+$' <<< "${__parser_data[1]}"; then
					local __parser_count="$(sed 's/^store//' <<< "${__parser_data[1]}")"
					__parser_data[1]="store${__parser_count},${__parser_count}"
				elif grep -qE '^store,[0-9]+$' <<< "${__parser_data[1]}"; then
					local __parser_count="$(sed 's/^store,//' <<< "${__parser_data[1]}")"
					__parser_data[1]="store0,${__parser_count}"
				elif grep -qE '^store[0-9]+,$' <<< "${__parser_data[1]}"; then
					local __parser_count="$(sed 's/^store//;s/,$//' <<< "${__parser_data[1]}")"
					__parser_data[1]="store${__parser_count},-1"
				else
					readarray -t __parser_count < <(sed 's/^store//;s/,/\n/' <<< "${__parser_data[1]}")
					if test "${__parser_count[0]}" -lt 0; then
						echo parser error: min number of args is less than 0 for flag "'${__parser_data[0]}'" >&2
						return 1
					elif test "${__parser_count[1]}" != '-1' -a "${__parser_count[0]}" -gt "${__parser_count[1]}"; then
						echo parser error: max number of args is less than min args for flag "'${__parser_data[0]}'" >&2
						return 1
					elif test "${__parser_count[0]}" = 0 -a "${__parser_count[1]}" = 0; then
						__parser_data[1]="bool"
					fi
				fi
				;;
			*)
				echo parser error: unrecognized flag type "'${__parser_data[1]}'" >&2
				return 1
				;;
		esac
		__parser_args+=("$(printf '%s;%s;%s;%s;%s' "${__parser_data[@]}")")
	done

	readarray -t __parser_varname_count < <(printf '%s\n' "${__parser_args[@]}" | cut -f3 -d\; | grep '\S' | sort | uniq -c)
	if printf "%s\n" "${__parser_varname_count[@]}" | grep -vE '^\s+1' | grep -q '\S'; then
		echo parser error: variable name is being overriden, printing naming count >&2
		printf "%s\n" "${__parser_varname_count[@]}" >&2
		return 1
	fi

	readarray -t __parser_flags_count < <(printf '%s\n' $(printf '%s\n' "${__parser_args[@]}" | cut -f1 -d\;) | sort | uniq -c)
	if printf "%s\n" "${__parser_flags_count[@]}" | grep -vE '^\s+1' | grep -q '\S'; then
		echo parser error: repeated flags in existance, printing flag count >&2
		printf "%s\n" "${__parser_flags_count[@]}" >&2
		return 1
	fi
	printf "%s\n" "${__parser_args[@]}"
}

__parser_parse_args() {
	read -t 0
	if test "$?" = 0; then
		readarray -t __parser_args < <(cat -)
	else
		echo __PARSER_ERROR=1
		echo parser error: could not read made args from stdin >&2
		return 1
	fi

	local __parser_arg_or_flag=""
	local __parser_positional_args=()
	local __parser_already_parsed=()
	while test "$#" -gt 0; do
		if grep -qE '^-' <<< "$1"; then
			if test "$1" = --; then
				shift
				__parser_positional_args+=("$@")
				break
			fi
			__parser_arg_or_flag=""
			if grep -qE '^-\w\S' <<< "$1"; then
				__parser_opts=("$(grep -oE '^-\w' <<< "$1")")
				__parser_tmp="$(sed -E 's/^-[a-z0-9]//i' <<< "$1")"
				__parser_arg_or_flag=true
				if test -n "$__parser_tmp"; then
					__parser_opts+=("$__parser_tmp")
				fi
				shift
				set -- "${__parser_opts[@]}" "$@"
			elif grep -qiE '^--\w[a-z0-9-]+=' <<< "$1";then
				readarray -t __parser_opts < <(sed 's/=/\n/' <<< "$1")
				shift
				set -- "${__parser_opts[@]}" "$@"
			fi
			readarray -t __parser_matching_flags < <(printf '%s\n' "${__parser_args[@]}" | grep -E -- "(^|\s)$(printf '[%s]' $(grep -o . <<< "$1"))(\s|;)")
			case "${#__parser_matching_flags[@]}" in
				0)
					if test -z "$PARSER_HYPHEN_VALUES"; then
						echo __PARSER_ERROR=1
						echo usage error: unrecognized flag "'$1'" >&2
						echo >&2
						echo 1 | __parser_print_help "${__parser_args[@]}"
						return 1
					else
						__parser_positional_args+=("$1")
					fi
					;;
				1)
					readarray -t __parser_data < <(__parser_var_parse <<< "$__parser_matching_flags")
					local __parser_id="$(cut -f1 -d' ' <<< "${__parser_data[0]}")"
					unset __parser_skip
					if printf '%s\n' "${__parser_already_parsed}" | grep -qE -- "^$(printf '[%s]' $(grep -o . <<< "$__parser_id"))$"; then
						case "$PARSER_OVERRIDE_FLAGS" in
							first)
								__parser_skip=true
							;;
							last)
								__parser_skip=false
							;;
							*)
								echo __PARSER_ERROR=1
								echo usage error: repeated flag "'$1'" >&2
								echo >&2
								echo 1 | __parser_print_help "${__parser_args[@]}"
								return 1
							;;
						esac
					fi
					if test "$__parser_skip" != true; then
						case "${__parser_data[1]}" in
							bool)
								test -n "$__parser_skip" || __parser_already_parsed+=("$__parser_id")
								eval "${__parser_data[2]}=true"
								;;
							append)
								eval "${__parser_data[2]}+=(\"$2\")"
								shift
								__parser_arg_or_flag=""
								;;
							count)
								if test -z "$(eval "echo \$${__parser_data[2]}")"; then
									eval "${__parser_data[2]}=1"
								else
									eval "${__parser_data[2]}=\$((${__parser_data[2]}+1))"
								fi
								;;
							store*)
								if test -z "$__parser_skip"; then
									__parser_already_parsed+=("$__parser_id")
								else
									eval "unset ${__parser_data[2]}"
								fi
								__parser_strip="$(sed 's/^store//' <<< "${__parser_data[1]}")"
								__parser_min="$(cut -d, -f1 <<< "$__parser_strip")"
								__parser_max="$(cut -d, -f2 <<< "$__parser_strip")"
								__parser_count=0
								while test "$__parser_count" != "$__parser_max" -a "$#" -gt 1 && ! grep -q '^-' <<< "$2"; do
									eval "${__parser_data[2]}+=(\"$2\")"
									shift
									__parser_count=$((__parser_count+1))
								done
								if test "$__parser_count" -lt "$__parser_min"; then
									if test "$__parser_min" = "$__parser_max"; then
										__parser_expect="(expected $__parser_min)"
									else
										__parser_expect="(expected at least $__parser_min)"
									fi
									echo __PARSER_ERROR=1
									echo usage error: not enough arguments given to flag "'$1'" $__parser_expect >&2
									echo >&2
									echo 1 | __parser_print_help "${__parser_args[@]}"
									return 1
								fi
								if test "$__parser_count" -gt 0; then
									__parser_arg_or_flag=""
								fi
								;;
						esac
					fi
					;;
				*)
					echo __PARSER_ERROR=1
					echo usage error: multiple compatible flags for argument "'$1'" >&2
					echo >&2
					echo 1 | __parser_print_help "${__parser_args[@]}"
					return 1
					;;
			esac
			if test -n "$__parser_arg_or_flag"; then
				__parser_saved="$2"
				shift 2
				set -- "-$__parser_saved" "$@"
			else
				shift
			fi
		else
			__parser_positional_args+=("$1")
			shift
		fi
	done

	echo 'unset __PARSER_ERROR'
	for __parser_var in $(printf '%s\n' "${__parser_args[@]}" | cut -f3 -d\;); do
		eval "echo $__parser_var=\(\$(printf \"'%s'\n\" \"\${${__parser_var}[@]}\" )\)"
	done
	echo "set -- $(printf "'%s' " "${__parser_positional_args[@]}")"
}

__parser_print_help() {
	read -t 0
	if test "$?" = 0; then
		local __parser_return_code="$(cat -)"
	fi
	local __parser_usage=("$(basename "$0")")
	local __parser_help=()
	local __parser_help_prefix="  "
	local __parser_or=","
	
	for __parser_arg in "$@"; do
		readarray -t __parser_data < <(__parser_var_parse <<< "$__parser_arg")
		case "${__parser_data[1]}" in
			bool)
				__parser_usage+=("[$(sed 's/ .*//' <<< "${__parser_data[0]}")]")
				__parser_help+=("${__parser_help_prefix}$(printf '%s, ' ${__parser_data[0]} | sed 's/, $//')$(printf '\t')${__parser_data[4]}")
				;;
			store*)
				__parser_strip="$(sed 's/^store//' <<< "${__parser_data[1]}")"
				__parser_min="$(cut -d, -f1 <<< "$__parser_strip")"
				__parser_max="$(cut -d, -f2 <<< "$__parser_strip")"
				if test "$__parser_min" = 0 -a "$__parser_max" = 1; then
					__parser_metavar="[${__parser_data[3]}]"
				elif test "$__parser_min" = 1 -a "$__parser_max" = 1; then
					__parser_metavar="${__parser_data[3]}"
				elif test "$__parser_min" = 0; then
					__parser_metavar="[${__parser_data[3]}...]"
				else
					__parser_metavar="${__parser_data[3]}..."
				fi
				__parser_usage+=("[$(sed 's/ .*//' <<< "${__parser_data[0]}") ${__parser_metavar}]")
				__parser_help+=("${__parser_help_prefix}$(printf "%s, " ${__parser_data[0]} | sed 's/, $//') ${__parser_metavar}$(printf '\t')${__parser_data[4]}")
				;;
			append)
				__parser_usage+=("[$(sed 's/ .*//' <<< "${__parser_data[0]}") ${__parser_data[3]}]")
				__parser_help+=("${__parser_help_prefix}$(printf "%s, " ${__parser_data[0]} | sed 's/, $//') ${__parser_data[3]}$(printf '\t')${__parser_data[4]}")
				;;
		esac
	done

	if test -z "$__parser_return_code" -o "$__parser_return_code" = 0; then
		echo usage: "${__parser_usage[@]}" POSITIONAL_ARGS...
		echo ""
		echo options:
		printf '%s\n' "${__parser_help[@]}" | column -t -s $'\t'
	else
		echo usage: "${__parser_usage[@]}" POSITIONAL_ARGS... >&2
		return "$__parser_return_code"
	fi
}
# END OF PARSER

main "$@"
