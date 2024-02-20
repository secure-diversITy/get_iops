# get IOPS

IOPS = [I]nput/Output [O]perations [P]er [S]econd

## Description

This helper will guide you through the jungle of IOPS testing. 

It was created to identify issues within environments which are very I/O intensive (e.g. splunk>) and makes use of well known linux testing tools and their best practices.

Although this is provided without warranty of any kind (and you use it at your own risk), it was created in the hope of being useful.

## Currently supported

- bonnie++
- fio
- iozone

## Planned / in progress

- ioping (latency)

## Installation / Usage

~~~
cd /opt
git clone https://github.com/secure-diversITy/get_iops.git
cd get_iops

# NOTE: The following is a snapshot of the current help/usage.
# always use ./getiops.sh help to get the latest one.

./getiops.sh help




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
	-b | --batch		       will run in batch mode (avoid any output - Note: WIP)
	--nodiskop			skip warning about to stop disk operations
	--useram [X|auto]	       define a specific amount of RAM in MB (for cache calculations)
	--size [X]		       define test file size in MB (will be multiplied with 3)
	--path [path/mountpoint]	set the path to the storage you want to test

    bonnie++ only:
	--nowarn			skip warning about usage
        --nfiles [X]                    number of files to write
        --ndirs [X]                     number of directories to write
	--tests [X|default]		number of test runs

    fio only:
	--blocksize [X]		       define a non-default block size
        --cores [X|auto]                set the amount of cores

    iozone only:
	--rsizes "[X|default]"	       the record sizes to use (must be quoted if not "default")
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

~~~
