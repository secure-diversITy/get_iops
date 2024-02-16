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
VER=24.0
#
#########################################################################################
EPATH=$(dirname $0)         # detect path we're running in
VARFILE=libs/vars

[ ! -f $VARFILE ] && echo "ERROR: missing variable file <$VARFILE>" && exit
source $VARFILE

[ ! -d "$FUNCS" ]&& echo -e "\n\tERROR: cannot find $FUNCS path..." && exit

for fc in $(ls $FUNCS);do
    . $FUNCS/$fc
    if [ $? -ne 0 ];then
        echo -e "\tERROR: $FUNCS/$fc cannot be included! Aborted.."
        exit 3
    else
        echo -e "\t... $fc included"
    fi
done

F_USAGE(){
    echo -e "\nVersion: $VER\n"
    echo -e "\nBrought to you by secure diversITy (www.sicherevielfalt.de)\n"
    echo -e "\n\tSimply execute me to start interactive mode."
    echo -e "\tYou can also switch to batch mode but this will use predefined values then:"
    echo -e "\n\t$0 [a1|a2|a3|a4]\n\n\tWhere:\n"
    echo -e "\t[a1|1] = bonnie++"
    echo -e "\t[a2|2] = iozone"
    echo -e "\t[a3|3] = fio"
    echo -e "\t[a4|4] = ioping (I/O latency)"
    echo -e "\n\t(aX means automatic)\n\tIf you choose batch mode all output will be made in JSON format.\n"
}

CHOICE="$1"
if [ "$CHOICE" == "-h" ]||[ "$CHOICE" == "--help" ];then F_USAGE; exit;fi

while [ -z $CHOICE ];do
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

# pre-check
case $CHOICE in
    1) bin="$BONBIN" ;;
    2) bin="$IZBIN" ;;
    3|4) echo coming soon; exit ;;
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
    a2) # auto iozone
        F_IOZONE 1
    ;;
    a3) # auto fio
        F_FIO 1
    ;;
    a4) # auto ioping
        F_IOPING 1
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
