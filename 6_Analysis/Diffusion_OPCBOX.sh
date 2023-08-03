#!/bin/sh

gfortran -O3 Diffusion_OPCBOX.f90 -o Diffusion_OPCBOX.exe

cat << EOS > in
parm ../1_Leap/Wat.parm7
trajin ../5_MD/md.nc
trajout md.dcd
EOS

cpptraj < in

./Diffusion_OPCBOX.exe -dcd md.dcd 

cat > in << + 
f(x) = 6.0*D*x + C
fit [10:500] f(x) "msd.dat" u (\$1*2):8:(\$9+0.0001) via D, C
+

rm fit.log
gnuplot < in
echo "# Diffusion coefficient in A^2/ps" > D.dat
grep "^D" fit.log | grep "%" | awk '{print $3}' >> D.dat
cat D.dat

rm -f in md.dcd fit.log

