#!/usr/bin/env bash
# Select a queued Condor worker job and follow its Out file, then return to the picker.
set -uo pipefail

show_error() {
	printf '\n%s\nPress Enter to return to the queue picker.' "$*" >&2
	IFS= read -r _ || :
}

queue_snapshot() {
	local output rc raw rest n cluster proc owner status qdate out err iwd cmd started now seconds elapsed status_name submitted id display_iwd trimmed parent
	output=$(condor_q -nobatch -af:t ClusterId ProcId Owner JobStatus QDate Out Err Iwd Cmd JobStartDate 2>&1)
	rc=$?
	if (( rc != 0 )); then
		show_error "condor_q failed (status $rc):"$'\n'"$output"
		return 1
	fi

	now=$(date +%s)
	while IFS= read -r raw; do
		[[ -n $raw ]] || continue
		rest=$raw
		local fields=()
		for n in {1..9}; do
			[[ $rest == *$'\t'* ]] || {
				show_error 'condor_q returned a malformed row (expected tab-separated fields).'
				return 1
			}
			fields+=("${rest%%$'\t'*}")
			rest=${rest#*$'\t'}
		done
		[[ $rest != *$'\t'* ]] || {
			show_error 'Tabs in Condor attributes are not supported.'
			return 1
		}
		fields+=("$rest")
		cluster=${fields[0]}
		proc=${fields[1]}
		owner=${fields[2]}
		status=${fields[3]}
		qdate=${fields[4]}
		out=${fields[5]}
		err=${fields[6]}
		iwd=${fields[7]}
		cmd=${fields[8]}
		started=${fields[9]}
		# The preview contains the complete path; retain just four trailing levels in the row.
		trimmed=${iwd%/}
		display_iwd=${trimmed##*/}
		for n in {1..3}; do
			parent=${trimmed%/*}
			[[ $parent != "$trimmed" && $parent != / ]] || break
			display_iwd=${parent##*/}/$display_iwd
			trimmed=$parent
		done
		[[ $display_iwd == "$iwd" ]] || display_iwd="…/$display_iwd"
		# DAGMan's controller is itself queued as a job; show its worker jobs instead.
		case ${cmd##*/} in condor_dagman) continue ;; esac
		id="$cluster.$proc"

		case $status in
			1) status_name=Idle ;;
			2) status_name=Running ;;
			3) status_name=Removed ;;
			4) status_name=Completed ;;
			5) status_name=Held ;;
			6) status_name=TransferringOutput ;;
			7) status_name=Suspended ;;
			8) status_name=TransferringInput ;;
			*) status_name="Status=$status" ;;
		esac
		printf -v status_name '%-7s' "$status_name"
		if [[ $qdate =~ ^[0-9]+$ ]]; then
			submitted=$(date -d "@$qdate" '+%F %R' 2>/dev/null) || submitted=$qdate
		else
			submitted=$qdate
		fi
		[[ $started =~ ^[1-9][0-9]*$ ]] || started=$qdate
		elapsed=-
		if [[ $started =~ ^[1-9][0-9]*$ ]]; then
			seconds=$(( now - started ))
			if (( seconds >= 0 )); then
				printf -v elapsed '%dh%dmin' "$(( seconds / 3600 ))" "$(( seconds / 60 % 60 ))"
			fi
		fi
		# Field 9 is last in raw rows, so fzf retains no delimiter after it.
		# Supply exactly one space before field 8 in --with-nth=1,2,4,9,8.
		printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s \n' \
			"$id" "$status_name" "$owner" "$submitted" "$out" "$err" "$iwd" "$display_iwd" "$elapsed"
	done <<< "$output"
}

pick() {
	# Ignore user defaults that could change the output protocol or add actions.
	FZF_DEFAULT_OPTS= FZF_DEFAULT_OPTS_FILE=/dev/null fzf \
		--height=100% --layout=reverse --no-multi --no-sort \
		--delimiter=$'\t' --with-nth=1,2,4,9,8 --tabstop=1 \
		--preview 'out={5}; iwd={7}; elapsed={9};
			elapsed=${elapsed% };
			if [[ $elapsed == - ]]; then elapsed=; else elapsed=" ($elapsed)"; fi
			printf "Working directory:\n%s\n\nOut: %s%s\n" "$iwd" "$out" "$elapsed"
			case $out in
				""|undefined|UNDEFINED|error|ERROR|"\"\"") exit 0 ;;
			esac
			[[ $out = /* ]] || out="${iwd%/}/$out"
			if [[ -r $out ]]; then
				lines=$(( ${FZF_PREVIEW_LINES:-12} - 4 ))
				(( lines > 0 )) && tail -n "$lines" -- "$out"
			else
				printf "(Out file is not readable yet.)\n"
			fi' \
		--preview-window 'down,40%,wrap' \
		--bind 'alt-p:toggle-preview,ctrl-f:page-down,ctrl-b:page-up' "$@"
}

selection_position() {
	local rows=$1 selected_id=$2 query=$3 filtered row id position=0
	[[ -n $selected_id ]] || return 1

	if [[ -n $query ]]; then
		filtered=$(printf '%s' "$rows" | FZF_DEFAULT_OPTS= FZF_DEFAULT_OPTS_FILE=/dev/null fzf \
			--filter="$query" --no-sort --delimiter=$'\t' --with-nth=1,2,4,9,8) || return 1
	else
		filtered=$rows
	fi

	while IFS= read -r row; do
		((position++))
		id=${row%%$'\t'*}
		if [[ $id == "$selected_id" ]]; then
			printf '%s' "$position"
			return 0
		fi
	done <<< "$filtered"
	return 1
}

resolve_output() {
	local out=$1 iwd=$2
	case $out in ''|undefined|UNDEFINED|error|ERROR|'""') return 1 ;; esac
	if [[ $out != /* ]]; then
		[[ $iwd == /* ]] || return 1
		out="${iwd%/}/$out"
	fi
	RESOLVED_OUT=$out
}

for tool in condor_q fzf less date; do
	command -v "$tool" >/dev/null 2>&1 || {
		show_error "Required command not found: $tool"
		exit 1
	}
done

query=
selected_id=
while :; do
	rows=$(queue_snapshot) || continue
	position=$(selection_position "$rows" "$selected_id" "$query") || position=
	picker_args=(
		--print-query
		--expect=ctrl-r,ctrl-e,ctrl-q
		--query="$query"
		--prompt='Condor queue> '
		--header='Enter: follow Out | Ctrl-E: follow Err | Ctrl-Q: condor_q | Ctrl-R: refresh | Esc: close (DAGMan controllers hidden)'
	)
	if [[ -n $position ]]; then
		picker_args+=(--bind "load:pos($position)")
	fi
	choice=$(printf '%s' "$rows" | pick "${picker_args[@]}")
	rc=$?
	case $rc in
		0|1) ;;
		130) exit 0 ;;
		*) show_error "Queue picker failed (status $rc)."; query=; continue ;;
	esac

	# --print-query emits query, accepted key, and (if selected) the raw row.
	if [[ $choice != *$'\n'* ]]; then
		# Enter on an empty/no-match list: relaunch the picker for edits/refresh.
		query=
		continue
	fi
	query=${choice%%$'\n'*}
	rest=${choice#*$'\n'}
	key=${rest%%$'\n'*}
	if [[ $key == ctrl-r ]]; then continue; fi
	if [[ $key == ctrl-q ]]; then
		condor_q | less -R
		continue
	fi
	if (( rc == 1 )); then
		# Enter with a query that has no matches; reopen so the query can be edited.
		continue
	fi

	[[ $rest == *$'\n'* ]] || continue
	selection=${rest#*$'\n'}
	[[ -n $selection ]] || continue
	row=$selection
	fields=()
	for n in {1..8}; do
		[[ $row == *$'\t'* ]] || {
			show_error 'The selected queue row was malformed.'
			continue 2
		}
		fields+=("${row%%$'\t'*}")
		row=${row#*$'\t'}
	done
	[[ $row != *$'\t'* ]] || {
		show_error 'Tabs in Condor paths are not supported.'
		continue
	}
	id=${fields[0]}
	selected_id=$id
	out=${fields[4]}
	err=${fields[5]}
	iwd=${fields[6]}
	log_kind=Out
	if [[ $key == ctrl-e ]]; then
		out=$err
		log_kind=Err
	fi
	if ! resolve_output "$out" "$iwd"; then
		show_error "$log_kind or Iwd is unset for $id."
		query=
		continue
	fi
	out=$RESOLVED_OUT

	printf 'Waiting for %s to be created...\n' "$out"
	while [[ ! -f $out ]]; do sleep 1; done
	if [[ ! -r $out ]]; then
		show_error "Out file is not readable: $out"
		query=
		continue
	fi
	export LESSOPEN= LESSCLOSE=
	less +F -R -- "$out"
done
