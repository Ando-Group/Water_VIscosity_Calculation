#!/usr/bin/python3

import sys
import numpy as np
import scipy.signal as sig

args = sys.argv
dt = float(args[1])
V = float(args[2])
T = float(args[3])

KB=1.380649

# mPa*s
f=float(V/KB/T*0.000001)

# Shear viscosity

filename = "Pxx.tmp"
x = np.loadtxt(filename, comments="#", unpack=True)
filename = "Pyy.tmp"
y = np.loadtxt(filename, comments="#", unpack=True)
filename = "Pzz.tmp"
z = np.loadtxt(filename, comments="#", unpack=True)

n1 = len(x)
n2 = int(n1/2)
acorr = np.zeros(n2)

xy = 0.5*(x-y)
xy = xy-np.mean(xy)
corr_buf = sig.correlate(xy,xy,mode="same")
corr = corr_buf[n1//2:]
nd = np.arange(n1,n1//2,-1)
corr /= nd
acorr += corr

yz = 0.5*(y-z)
yz = yz-np.mean(yz)
corr_buf = sig.correlate(yz,yz,mode="same")
corr = corr_buf[n1//2:]
nd = np.arange(n1,n1//2,-1)
corr /= nd
acorr += corr

zx = 0.5*(z-x)
zx = yz-np.mean(zx)
corr_buf = sig.correlate(zx,zx,mode="same")
corr = corr_buf[n1//2:]
nd = np.arange(n1,n1//2,-1)
corr /= nd
acorr += corr

acorr /= 3.0

s = np.zeros(n2)

for i in range(1,n2):
    s[i] = 0.5*dt * (acorr[i] + acorr[i-1]) + s[i-1]

fs = f*s

t = np.arange(0,n2)*dt

c = np.stack([t,acorr,s,fs])
c = np.transpose(c)

np.savetxt("acf_shear.dat",c,delimiter=" ")
