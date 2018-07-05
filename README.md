# LAMMPS-in-Azure
How to run LAMMPS Version 16 March 2018 in Azure with Virtual Machine Scale Sets (VMSS)

## Introduction

The purpose of this project is to demonstrate the possibility of running LAMMPS using Virtual Machine Scale Sets in the Azure HPC Infrastructure. LAMMPS is a classical molecular dynamics code, and an acronym for Large-scale Atomic/Molecular Massively Parallel Simulator. For more details please visit http://lammps.sandia.gov/. 

The source can be downloaded from https://sourceforge.net/projects/lammps/ 
Standard Benchmarks are collected in http://lammps.sandia.gov/bench.html

For this lab, it is not neccessary to download anything. The script below will download precompiled binaries and benchmark data. The VMs will be automatically deployed with CentOS 7.4 HPC and some necessary packages to run LAMMPS. We are using Version March 2018.

## Performance in Azure

Two graphs below show wallclock times for the performance for the Rhodopsin protein and the Bulk Cu EAM benchmark on the H16r series in Azure using VMSS.  Each node has 16 cores. The benchmark was executed with 800 timesteps (Rhode) and 10000 steps (Cu). The number of timesteps can be modified in the last line of the inpu file.

<img src="https://github.com/schoenemeyer/LAMMPS-in-Azure/blob/master/lammps.png" width="382"> <img src="https://github.com/schoenemeyer/LAMMPS-in-Azure/blob/master/lammp-cupng.png" width="382">

## How to run

These are the basic steps in this lab:

1. Open a [Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) session from the Azure Portal, or open a Linux session with Azure CLI v2.0, jq and zip packages installed. Here is the link how to install az cli on your workstation https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
2. Clone the repository, `git clone https://github.com/schoenemeyer/LAMMPS-in-Azure.git`
3. Grant execute access to scripts `chmod +x *.sh`
4. Create Virtual Machine Scale Set (https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview) for 2, 4, 8 or more nodes. Make sure you have enough quota to run your experiment. You can find on the portal a button for requesting higher core counts

The commands to be executed on your Linux Workstation
```
az login
az account show
```
will show the available ids, e.g. "id": c45f88-90......4r" and the parameter "isDefault" must be true. If you have several ids, make sure to set true to the id, you want to use.
```
az account set -s "your preferred subscription id"
```
before you start the vmss script below, please consider the choice of your preferred region. A list of Azure regions can be found here https://azure.microsoft.com/en-us/global-infrastructure/regions/

Decide for the number of nodes you are going to run, e.g. 2, and you will get a cluster with 2 nodes connected with FDR and CentOS 7.4 images with Intel MPI 5.1.3.223. Make sure you set your username correctly in the third line in the script vmss-lammps.sh.
```
./vmss-lammps.sh 2
```
After the VMSS is created, you will see the command how to connect to the first VM of your cluster
```
ssh username@<ip> -p 50000
```
Doublecheck whether the hostname is correctly set in the hostfile and start installation and running the benchmark:
```
./install-run-lam.sh
```
