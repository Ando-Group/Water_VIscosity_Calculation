# Water_Viscosity_Calculation
Set of files for computing water properties from MD simulations using AMBER.
Input files for AMBER MD, programs, and script files for analysis were writen by Ando at Tokyo University of Science
Trajectory files and energy output files are not uploaded here due to their large file sizes.
But, some of the output files from MD simulations and analysis are included.

1_Leap: Prepare topology and coordinate files for 2000 OPC waters in a cubic box.
  tleap -f leap.in

2_Min: Energy minimize of the simulation system.
  ./run.sh 

3_Equil: Equilibrate the system for 1 ns at 298 K and 1 bar using the Langevin thermostat and Berendesen batostat. 
  ./run.sh

4_Equil: Equilibrate the system again for 1 ns at 298 K and 1 bar using the Langevin thermostat and Berendesen batostat. 
  ./run.sh

5_MD: Production run for 10 ns under NVT conditions.
  ./run.sh

6_Analysis: Analyzing simulation data.
  To compute shear viscosity of the water,
    ./Viscostiy_calculation.sh
  To compute dielectric constant of the wter,
    ./Dielectric_OPCBOX.sh
  To compute diffusion coefficient of the water,
    ./Diffusion_OPCBOX.sh

  
