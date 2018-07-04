# LAMMPS-in-Azure
How to run LAMMPS March 2018 in Azure with VMSS

## Introduction

The purpose of this project is to demonstrate the possibility of running LAMMPS using Virtual Machine Scale Sets in the Azure HPC Infrastructure. LAMMPS is a classical molecular dynamics code, and an acronym for Large-scale Atomic/Molecular Massively Parallel Simulator. For more details please visit http://lammps.sandia.gov/. 

The source can be downloaded from https://sourceforge.net/projects/lammps/ 
Standard Benchmarks are collected in http://lammps.sandia.gov/bench.html


## Performance in Azure

Here is the performance for the Rhodopsin protein benchmark on the H16r series in Azure using VMSS.  Each node has 16 cores.

<img src="https://github.com/schoenemeyer/LAMMPS-in-Azure/blob/master/lammps.png" width="452">




