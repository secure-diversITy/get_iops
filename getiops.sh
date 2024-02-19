#!/bin/bash
###########################################################################################
#
# Source:       https://github.com/secure-diversITy/get_iops
# Copyright:    2015-2024 Thomas Fischer <mail |AT| sedi #DOT# one>
# License:      CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/)
#
# Desc:         Stress your storage setup to find out IOPS
#
###########################################################################################
#
# Usage & Installation: Checkout README !!
#
#########################################################################################
#
VER=24.1
#
#########################################################################################
EPATH=$(dirname $0)         # detect path we're running in
VARFILE=libs/vars
DEBUG=0

[ ! -f $VARFILE ] && echo "ERROR: missing variable file <$VARFILE>" && exit
source $VARFILE

[ ! -d "$FUNCS" ]&& echo -e "\n\tERROR: cannot find $FUNCS path..." && exit

for fc in $(ls $FUNCS);do
    . $FUNCS/$fc
    if [ $? -ne 0 ];then
        echo -e "\tERROR: $FUNCS/$fc cannot be included! Aborted.."
        exit 3
    else
        [ $DEBUG -eq 1 ] && echo -e "\t... $fc included"
    fi
done

F_USAGE(){

cat << _EOHELP

Version: $VER
A simple helper to guide you through the jungle of IOPS testing.
Brought to you by secure diversITy (www.sicherevielfalt.de)

Simply execute ./getiops.sh to start the interactive mode.

The following CLI parameters exist which will skip interactive questions:
    
    general:
	-t | --type [1|2|3|4]		sets the type (1 = bonnie++, 2 = iozone, 3 = fio, 4 = ioping (I/O latency))
	-b | --batch		        will run in batch mode (avoid any questions - Note: WIP)
	--nodiskop			skip warning about to stop disk operations
	--useram [X|auto]	        define a specific amount of RAM in MB (for cache calculations)
	--size [X]		        define test file size in MB (will be multiplied with 3)
	--path [path/mountpoint]	set the path to the storage you want to test
	--tests [X|default]		set the tests to run (type specific)

    bonnie++ only:
	--nowarn			skip warning about usage
        --nfiles [X]                    number of files to write
        --ndirs [X]                      number of directories to write

    fio only:
	--blocksize [X]		        define a non-default block size
        --cores [X|auto]                set the amount of cores

    iozone only:
	--rsizes [X|default]	        the record sizes to use
	--cores [X|auto]		set the amount of cores to use for throughput mode

interactive mode can be mixed with those parameters, i.e. if you do not specify all
possible parameters for a type you will be prompted

_EOHELP

}

# check/set args
while [ ! -z "$1" ]; do
    case "$1" in
        -h|--help|help) F_USAGE; exit;;
        -t|--type) CHOICE=$2; shift 2;;
        -a|--batch) BATCH=1; shift ;;
        --nowarn) export SKIPWARN=y; shift ;;
        --nodiskop) export IOPROC=y; shift ;;
        --useram|--size) export RAM="$2"; shift 2;;
        --path) export STORAGE="$2"; shift 2;;
        --tests) export TESTS="$2"; shift 2;;
        --rsizes) export RSIZES="$2"; shift 2;;
        --blocksize) export BLKSIZE="$2"; shift 2;;
        --cores|--jobs) export CPUCOUNT="$2"; shift 2;;
        --nfiles) export NFILES="$2"; shift 2;;
        --ndirs) export NDIRS="$2"; shift 2;;
        *) echo "unknown arg: $1"; F_USAGE; exit 4;;
    esac
done

while [ -z "$CHOICE" ];do
    # users choice
    echo -e "\n\tWelcome and tighten your seat belts. We are about to stress your storage setup!"
    echo -e "\tThere are several tools out there which can measure things. The question is which of those"
    echo -e "\tis doing it the right way?\n\tThe short answer? Test them all ;)\n"
    echo -e "\tNow let's start. Which tool do you want to use today?\n"
    echo -e "\t[1] = bonnie++"
    echo -e "\t[2] = iozone"
    echo -e "\t[3] = fio"
    echo -e "\t[4] = ioping (I/O latency only)"
    echo
    read -p "type in the digit from above: > " CHOICE
done

# pre-check binaries
case $CHOICE in
    1) bin="$BONBIN" ;;
    2) bin="$IZBIN" ;;
    3) bin="$FIOBIN";;
    4) echo coming soon; exit ;;
    *)echo -e "\nERROR: invalid choice >$CHOICE<\n"; F_USAGE; exit 4 ;;
esac
if [ ! -x $bin ];then
    echo -e "\n\tERROR: Cannot find $bin or it is not executable! ABORTED.\n"
    exit 3
else
    echo -e "\t.. $bin detected correctly"
fi

# do what the user want to do
# the first argument when exec a function is always the batch mode.
# 0 means interactive. 1 means batch mode.
case $CHOICE in
    a1) # auto bonnie
        CSV="$CSVPATH/bonnie++.csv"
        [ -f "$CSV" ]&& rm -vf "$CSV" && echo "...deleted previous stats file $CSV"
        F_BONNIE 1
    ;;
    1) # bonnie
        F_BONNIE 0
    ;;
    2) # iozone
        F_IOZONE 0
    ;;
    3) # fio
        F_FIO 0
    ;;
    4) # ioping
        F_IOPING 0
    ;;
esac

echo -e "\n\n$TYPE finished! You can find the result CSV here: $CSV"
