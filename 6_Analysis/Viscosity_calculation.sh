#!/bin/sh

# Time interval (ps)
DT=0.01

V=`awk '{print $2}' ../5_MD/summary_avg.VOLUME`
T=`awk '{print $2}' ../5_MD/summary_avg.TEMP`

grep "L3" ../5_MD/ene.out | tail -n +2 | awk '{print $3}' > Pxx.tmp
grep "L3" ../5_MD/ene.out | tail -n +2 | awk '{print $4}' > Pyy.tmp
grep "L3" ../5_MD/ene.out | tail -n +2 | awk '{print $5}' > Pzz.tmp

./acf.py $DT $V $T

rm Pxx.tmp Pyy.tmp Pzz.tmp 

