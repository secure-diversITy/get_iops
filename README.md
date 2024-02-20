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
	-t | --type [1|2|3|4]		    sets the type (1 = bonnie++, 2 = iozone, 3 = fio, 4 = ioping (I/O latency))
	-b | --batch		            will run in batch mode (avoid any questions - Note: WIP)
	--nodiskop			            skip warning about to stop disk operations
	--useram [X|auto]	            define a specific amount of RAM in MB (for cache calculations)
	--size [X]		                define test file size in MB (will be multiplied with 3)
	--path [path/mountpoint]	    set the path to the storage you want to test
	--tests [X|default]		        set the tests to run (type specific)

    bonnie++ only:
	--nowarn			            skip warning about usage
    --nfiles [X]                    number of files to write
    --ndirs [X]                     number of directories to write

    fio only:
	--blocksize [X]		            define a non-default block size
    --cores [X|auto]                set the amount of cores

    iozone only:
	--rsizes [X|default]	        the record sizes to use
	--cores [X|auto]		        set the amount of cores to use for throughput mode

interactive mode can be mixed with those parameters, i.e. if you do not specify all
possible parameters for a type you will be prompted
~~~
