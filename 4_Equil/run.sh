#!/bin/sh

pmemd.cuda -O -i eq.in -p ../1_Leap/Wat.parm7 -c ../3_Equil/eq.rst7 -o eq.out -r eq.rst7 -x eq.nc -e ene.out

