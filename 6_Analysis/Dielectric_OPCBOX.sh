#!/bin/sh

gfortran -O3 Dielectric_OPCBOX.f90 -o Dielectric_OPCBOX.exe

cat << EOS > in
parm ../1_Leap/Wat.parm7
trajin ../5_MD/md.nc
trajout md.dcd
EOS

cpptraj < in

TTT=`awk '{print $2}' ../5_MD/summary_avg.TEMP`
./Dielectric_OPCBOX.exe -dcd md.dcd -temp $TTT > dielectric.dat
cat dielectric.dat

rm in md.dcd

