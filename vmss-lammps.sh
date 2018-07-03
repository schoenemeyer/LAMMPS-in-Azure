#!/bin/bash
#Usage vmsscreate.sh <numberofnodes> 
#Custom IMAGE
echo -n "Do you want to delete the VM Scaleset (y/n)? "
read answerd
if [ "$answerc" != "${answerd#[Nn]}" ] ;then
az vmss delete  --name lammps --resource-group lamlab
exit
else
    echo "Scaleset still alive"
fi
echo -n "Do you want to create a new Resource Group Scaleset (y/n)? "
read answera
if [ "$answera" != "${answera#[Yy]}" ] ;then
az group create -n lamlab -l northeurope  
else
    echo "No Resource Group Scaleset created"
fi
echo -n "Do you want to create a new VM Scaleset (y/n)? "
read answerb
if [ "$answerb" != "${answerb#[Yy]}" ] ;then
az vmss create --name lamconus --resource-group lamlab --image OpenLogic:CentOS-HPC:7.4:7.4.20180301 --vm-sku Standard_H16r --storage-sku Standard_LRS --instance-count $1 --authentication-type ssh  --single-placement-group true --output tsv --disable-overprovision --ssh-key-value /home/thomas/.ssh/id_rsa.pub
else
    echo "No Scaleset created"
fi
echo "List Connection Info "
sleep 10s
rm -f list-instance node1 hostnamem
az vmss list-instance-connection-info --name lamconus --resource-group lamlab >> list-instance
cat list-instance
grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' list-instance >> node1
cat node1
ipm=$(head -n 1 node1)
echo "The IP of the master node= " $ipm
cat << EOF > ./msglen.txt
2
8
EOF
scp -P 50000 ~/.ssh/id_rsa thomas@$ipm:/home/thomas/.ssh
scp -P 50000 ~/.ssh/id_rsa.pub  thomas@$ipm:/home/thomas/.ssh
scp -P 50000 ./msglen.txt thomas@$ipm:/home/thomas
echo "Connect  ssh thomas@"$ipm" -p 50000 "
ssh  thomas@"$ipm" -p 50000 /bin/bash << EOF
hostname > hostnamem
EOF
scp -P 50000 thomas@$ipm:/home/thomas/hostnamem .
cat hostnamem
echo "create hostlist" 
namehost=$(cat hostnamem)
rm -f hostfile
# Create hostfile for MPI Command
echo "$namehost" | rev | cut -c 2- | rev > naho
nah=$(cat naho)
for (( i=0; i<$1; i++))
   do
   echo " $nah$i" >> hostfile
   done
cat hostfile
scp -P 50000 ./hostfile thomas@$ipm:/home/thomas
#Deploy gcc5.3.1 installation on all nodes
for (( i=0; i<$1; i++))
   do
    ssh  thomas@"$ipm" -p 5000$i hostname > hostnamem
    ssh  thomas@"$ipm" -p 5000$i sudo yum -y install centos-release-scl
    ssh  thomas@"$ipm" -p 5000$i sudo yum -y install devtoolset-4-gcc*
   done
 
echo "create scp-script" 
rm -f install-run-lam.sh
echo "#!/bin/bash" >> install-run-lam.sh
echo "ulimit -s unlimited" >> install-run-lam.sh
echo "export LD_LIBRARY_PATH=./:"'$'"LD_LIBRARY_PATH"  >> install-run-lam.sh
echo "export INTELMPI_ROOT=/opt/intel/impi/5.1.3.223 " >> install-run-lam.sh
echo "export I_MPI_FABRICS=shm:dapl " >> install-run-lam.sh
echo "export I_MPI_DAPL_PROVIDER=ofa-v2-ib0 " >> install-run-lam.sh
echo "source /opt/intel/impi/5.1.3.223/bin64/mpivars.sh " >> install-run-lam.sh
echo "scl enable devtoolset-4 " >> install-run-lam.sh
echo " wget https://hpccenth2lts.blob.core.windows.net/lammps/lammps.zip"  >> install-run-lam.sh 
echo " unzip lammps.zip"  >> install-run-lam.sh 
echo " rm lam.zip"  >> install-run-lam.sh 
for (( i=1; i<$1; i++))
   do
   echo "scp -r * thomas@$nah$i:/home/thomas" >> install-run-lam.sh
   done
echo " mpirun -np " $((16*$1)) " -perhost 16 -hostfile ./hostfile ./lmp_mpi -in ./in.rhodo" >> install-run-lam.sh
scp -P 50000 ./install-run-lam.sh thomas@$ipm:/home/thomas

echo "export INTELMPI_ROOT=/opt/intel/impi/5.1.3.223 "
echo "export I_MPI_FABRICS=shm:dapl "
echo "export I_MPI_DAPL_PROVIDER=ofa-v2-ib0 "
echo "source /opt/intel/impi/5.1.3.223/bin64/mpivars.sh "

echo " ####################################### "
echo " LAMMPS "
echo " ####################################### "
echo " wget https://hpccenth2lts.blob.core.windows.net/lam/lammps.zip"
echo " unzip lam"
echo " rm lammps.zip"
echo " run ./install-run-lam.sh"
echo " scp -r * thomas@lamvma244000001:/home/thomas "
echo " export LD_LIBRARY_PATH=./:"'$'"LD_LIBRARY_PATH"
echo " no shared FS needed"
echo " ulimit -s unlimited"
echo " mpirun -np $((16*$1)) -perhost 16 -hostfile ./hostfile ./lmp_mpi -in ./in.rhodo "

echo "Connect  ssh thomas@"$ipm" -p 50000 "
echo "./install-run-lam.sh"
echo "Content of your hostfile "
cat hostfile
echo -n "Do you want to delete the new VM Scaleset (y/n)? "
read answerc
if [ "$answerc" != "${answerc#[Yy]}" ] ;then
az vmss delete  --name lamconus --resource-group lamlab
else
    echo "Scaleset still alive"
fi
