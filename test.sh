#!/bin/bash
CMD="test"
CMD_BOOT="test_boot"

while getopts "nbv:" flag
do
    case "${flag}" in
	v)
		echo V
		CMD="$CMD $OPTARG";;
        n) 
		echo N
		CMD=$CMD ;;

        b) 
		echo B
		CMD=$CMD_BOOT ;;
    esac
done
echo $CMD
