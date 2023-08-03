#!/bin/sh

pmemd.cuda -O -i md.in -p ../1_Leap/Wat.parm7 -c ../4_Equil/eq.rst7 -o md.out -r md.rst7 -x md.nc -e ene.out

process_mdout.perl md.out
