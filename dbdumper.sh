#!/usr/bin/env bash
#
# Copyright (c) 2013 Fabian Freiburg
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
###

BZIP2=
DBS=
DBS_TO_DUMP=
DBS_TO_IGNORE="information_schema"
DRYRUN=
HOST="localhost"
PATH_TO_SAVE=
TABLES=
TABLES_TO_DUMP=
TABLES_TO_IGNORE=
USER=`whoami`
VENDOR="mysql"

function usage()
{
	cat << EOF
usage: ${0} options

Script to dump SQL databases

OPTIONS:
  -b  compress the dumps with bzip2
  -d  space separated list of database name(s) (defaults to all databases, wildcards allowed)
  -D  space separated list of database name(s) to ignore (wildcards allowed)
  -H  database host (defaults to "localhost")
  -p  save path of the dumps; if not set, dumps will be pushed to STDOUT
  -t  not yet implemented: space separated list of table name(s) (defaults to all tables, wildcards allowed)
  -T  not yet implemented: space separated list of table name(s) to ignore (wildcards allowed)
  -u  user name (defaults to the user name running the script)
  -v  database vendor (either "mysql" or "pgsql", defaults to "mysql")
  -V  dry-run, commands are not going to be executed but printed
  -h  this help message
EOF
}

function getDatabasesFromHost()
{
	case ${VENDOR}
	in
		"mysql") DBS=`/usr/bin/env mysql -h ${HOST} -u ${USER} -Bse "SHOW DATABASES;"`;;
		"pgsql") DBS=`/usr/bin/env psql -h ${HOST} -U ${USER} -Atc "SELECT datname FROM pg_database WHERE datistemplate = false;"`;;
	esac
}

function getDatabasesToDump()
{
	local db

	for db in ${DBS}
	do
		local ignore=0

		if [[ -n ${DBS_TO_IGNORE} ]]
		then
			local i

			for i in ${DBS_TO_IGNORE}
			do
				[[ ${db} == ${i} ]] && ignore=1 || :
			done
		fi

		if [ ${ignore} -eq 0 ]
		then
			DBS_TO_DUMP="${DBS_TO_DUMP} ${db}"
		fi
	done
}

function getCompressCommand()
{
	case ${BZIP2}
	in
		1) echo "| /usr/bin/env bzip2";;
	esac
}

function getFileName()
{
	local filename="${PATH_TO_SAVE}/${1}_`date +%Y%m%d_%H%M%S`"

	case ${VENDOR}
	in
		"mysql") filename="${filename}.my.sql";;
		"pgsql") filename="${filename}.pg.sql";;
	esac

	case ${BZIP2}
	in
		1) filename="${filename}.bz2";;
	esac

	echo ${filename}
}

function getOut()
{
	if [[ -n ${PATH_TO_SAVE} ]]
	then
		echo "> $(getFileName ${1})"
	fi
}

function dumpDb()
{
	local cmd

	case ${VENDOR}
	in
		"mysql")
			cmd="/usr/bin/env mysqldump -h ${HOST} -u ${USER} --skip-comments ${1} $(getCompressCommand) $(getOut ${1})"
			;;
		"pgsql")
			cmd="/usr/bin/env pg_dump -h ${HOST} -U ${USER} ${1} $(getCompressCommand) $(getOut ${1})"
			;;
	esac

	if [[ -z ${DRYRUN} ]]
	then
		eval ${cmd}
	else
		echo ${cmd}
	fi
}

function dumpDbs()
{
	local db

	for db in ${DBS_TO_DUMP}
	do
		dumpDb ${db}
	done
}

function options()
{
	if [ ${#} -eq 0 ]
	then
		usage
		exit 0
	fi

	while getopts "bd:D:hH:p:t:u:v:V\?" OPTION
	do
		case ${OPTION}
		in
			b) BZIP2=1;;
			d) DBS=${OPTARG};;
			D) DBS_TO_IGNORE="${DBS_TO_IGNORE} ${OPTARG}";;
			H) HOST=${OPTARG};;
			p) PATH_TO_SAVE=${OPTARG};;
			t) TABLES=${OPTARG};;
			u) USER=${OPTARG};;
			v)
				if [[ "mysql pgsql" =~ ${OPTARG} ]]
				then
					VENDOR=${OPTARG}
				else
					usage
					exit
				fi
				;;
			V) DRYRUN=1;;
			h)
				usage
				exit
				;;
			*)
				usage
				exit
				;;
		esac
	done
}

function main()
{
	if [[ -z ${DBS} ]]
	then
		getDatabasesFromHost
	fi

	getDatabasesToDump

	if [[ -n ${DRYRUN} ]]
	then
		echo ${DBS_TO_DUMP}
	fi

	dumpDbs
}

options ${@}
main
