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
VER=24.4
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
Although this is provided without warranty of any kind (and you use it at your own risk), it was created in the hope of being useful.
Brought to you by secure diversITy (www.sicherevielfalt.de).

Simply execute ./getiops.sh to start the interactive mode.

The following CLI parameters exist which will skip interactive questions:
    
    general:
        -u | --user [username]          starting get_iops.sh as root requires a local user to actually run the tests
                                        ensure that this user has read+write access at your test path
                                        if you specify "root" as username it will proceed (on your own risk, of course)
	-t | --type [value]		sets the type:
                                        1 or "bonnie++", 2 or "iozone", 3 or "fio", 4 or "ioping"
                                        note: bonnie++ requires also iostat to be installed
	-b | --batch		        will run in batch mode (avoid any output - Note: WIP)
	--nodiskop			skip warning about to stop disk operations
	--useram [X|auto]	        define a specific amount of RAM in MB (for cache calculations)
	--size [X]		        define test file size in MB (will be multiplied with 3)
	--path [path/mountpoint]	set the path to the storage you want to test

    bonnie++ only:
	--nowarn			skip warning about usage
        --nfiles [X]                    number of files to write
        --ndirs [X]                     number of directories to write
	--tests [X|default]		number of test runs

    fio only:
	--blocksize [X]		        define a non-default block size
        --cores [X|auto]                set the amount of cores
        not available in interactive mode:
        --readperc [X|default]          percentage of a mixed workload that should be read (+ writeperc must be 100)
        --writeperc [X|default]         percentage of a mixed workload that should be written (+ readperc must be 100)
        --iodepth [X|default]           "default" is highly recommended here

    iozone only:
	--rsizes "[X|default]"	        the record sizes to use (must be quoted if not "default")
	--cores [X|auto]		set the amount of cores to use for throughput mode
        --tests "[X|default]"           tests to run (must be quoted, e.g. --tests "0 2 8"):
                                        0=write/rewrite, 1=read/re-read, 2=random-read/write, 3=Read-backwards, 4=Re-write-record
                                        5=stride-read, 6=fwrite/re-fwrite, 7=fread/Re-fread, 8=mixed workload, 9=pwrite/Re-pwrite
                                        10=pread/Re-pread, 11=pwritev/Re-pwritev, 12=preadv/Re-preadv

interactive mode can be mixed with those parameters, i.e. if you do not specify all
possible parameters for a type you will be prompted.

Additionally the following environment variables can be used to overwrite the default binary paths:

    IZBIN                               full path to your iozone binary
    FIOBIN                              full path to your fio binary
    BONBIN                              full path to your bonnie++ binary
    IOSTATBIN                           full path to your iostat binary (required for bonnie++)
    RESULTPATH                          full path where results should be stored

    simply export those before executing (e.g. export IZBIN=/usr/local/bin/iozone)
    or together with the running set (e.g. IZBIN=/usr/local/bin/iozone ./getiops.sh --type iozone ....)

_EOHELP

}

# check/set args
while [ ! -z "$1" ]; do
    case "$1" in
        -h|--help|help) F_USAGE; exit;;
        -t|--type) CHOICE=$2; shift 2;;
        -u|--user) RUNUSER=$2; shift 2;;
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
        --readperc) export FIOREADPERC="$2"; shift 2;;
        --writeperc) export FIOWRITEPERC="$2"; shift 2;;
        --iodepth) export FIOIODEPTH="$2"; shift 2;;
        *) echo "unknown arg: $1"; F_USAGE; exit 4;;
    esac
done

# check if we are root
if [ "$(id -u)" == 0 -a -z "$RUNUSER" ];then
    echo -e "\nERROR: You are running $0 as root but do not have specified a local user (-u|--user)"
    echo -e "If you really want to run as root specify -u root (not recommended)."
    echo -e "Software can have bugs and even though an unprivileged user can damage data,"
    echo -e "running as root can take serious damage to the whole system!\n"
    exit 4
fi

# setup run user
[ -z "$RUNUSER" ] && export RUNUSER="$(id -un)"
export BINARGS="sudo -u $RUNUSER"

# starting interactive mode
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
    1|bonnie++) bin="$BONBIN"
       if [ ! -x "$IOSTATBIN" ];then
         echo -e "\nrunning bonnie++ requires iostat to determine IOPS, which seems to be not installed\n"
         exit 3
       fi 
    ;;
    2|iozone) bin="$IZBIN" ;;
    3|fio) bin="$FIOBIN";;
    4|ioping) echo coming soon; exit ;;
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
    1|bonnie++) # bonnie++
        F_BONNIE 0
    ;;
    2|iozone) # iozone
        F_IOZONE 0
    ;;
    3|fio) # fio
        F_FIO 0
    ;;
    4|ioping) # ioping
        F_IOPING 0
    ;;
esac

echo -e "\n$TYPE finished! You can find the result CSV here: $CSV\n\n"
