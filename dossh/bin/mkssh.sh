#!/bin/bash
awk 'BEGIN {FS = ","} NR > 1 {print "Host " $2,$4 "\n    HostName " $4}' -
