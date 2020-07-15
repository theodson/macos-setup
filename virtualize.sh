#!/usr/bin/env bash

# #########################################################
#    Vagrant / VMWare
#     macOs VMWare Fusion helper functions 

# 
export VAGRANT_DEFAULT_PROVIDER=vmware_fusion


function vfindvm() {
  local __resultvar=${1:-vmid}
  local path=${2:-.}
  # try sub folder for VMs
  echo "searching subfolders for .vagrant" 
  local options=()
  local optionsid=()

  for vf in $(find $path -type f -path "*/.vagrant/machines/default/*/index_uuid"); do 
    optionid=$(printf "%b " "$(cat $vf)"); 
    option=$(printf "%b________%b\n" "$(cat $vf)" $vf);
    optionsid+=($optionid)    
    options+=($option)    
  done
  
  PS3='Which VM: '
  if (( ${#options[@]} )); then
  select opt in "${options[@]}"
  do
      case $opt in
          *) break
            ;;
      esac
  done  
  lvmid=${optionsid[$((REPLY-1))]}
  if [[ "$__resultvar" ]]; then
    eval $__resultvar="'$lvmid'"
  fi
  fi

}

function vssh() { 
  # Vagrant SSH
  if [ $# -eq 0 ]; then 
    vagrant ssh 2>/dev/null && return || echo 'no VM found in current folder'; 
  fi;
  # try arg as VM ID
  if [ $# -eq 1 ]; then 
    vagrant ssh $1 2>/dev/null && return || echo "no VM found with argument specified"
  fi
  # find VM and assign VMID to var_name passed 
  vfindvm vmid
  if [ ! -z "${vmid}" ];then 
    echo "trying ssh for $vmid"
    vagrant ssh $vmid
    echo "finished ssh for $vmid"
  else
    echo "no VMs found in subfolder"
  fi
  return 
}

function vrld() { 
  # Vagrant Reload
  if [ $# -eq 0 ]; then 
    vagrant reload 2>/dev/null && return || echo 'no VM found in current folder'; 
  fi;
  # try arg as VM ID
  if [ $# -eq 1 ]; then 
    vagrant reload $1 2>/dev/null && return || echo "no VM found with argument specified"
  fi
  # find VM and assign VMID to var_name passed 
  vfindvm vmid
  if [ ! -z "${vmid}" ];then 
    echo "trying reload for $vmid"
    vagrant reload $vmid
    echo "finished reload for $vmid"
  else
    echo "no VMs found in subfolder"
  fi    
  return 
}

function vkill() {
  # find VM and assign VMID to var_name passed 
  vfindvm vmid
  if [ ! -z "${vmid}" ];then  
    echo "trying destroy for $vmid"
    vagrant destroy -f $vmid
    echo "finished destroy for $vmid"
  else
    echo "no VMs found in subfolder"
  fi
}


function vstat() {
  # find VM and assign VMID to var_name passed 
  vfindvm vmid
  if [ ! -z "${vmid}" ];then 
    echo "trying status for $vmid"
    vagrant status $vmid
    echo "finished status for $vmid"
  else
    echo "no VMs found in subfolder"
  fi        
}


function launchVM() {
    [ $# -ne 1 ] && echo "Specify a path to an OVA file to use."
    SRC_OVF=$1

    vm_name=${1:-$(date +%F-%H%M%S)}
    vm_path=${2:-vms}/$vm_name
    mkdir -p $vm_path && ovftool $SRC_OVF $vm_path/${vm_name}.vmx && vmrun -T fusion start $vm_path/${vm_name}.vmx
    
    # vmrun -T fusion addNetworkAdapter ${vm_name}.vmx bridged && vmrun -T fusion start ${vm_name}.vmx
}




# VMWare Tools
alias ovftool='/Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool/ovftool'
alias vmnet-cli='/Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli'

# Docker
alias dock_prune='docker container prune'

# Vagrant
alias vglob='vagrant global-status --prune 2>/dev/null | egrep -i --color=always "^.*$(pwd)[ ]*$|$"'
#alias v_glob='vagrant global-status --prune 2>&1 | grep -v VAGRANTFILE_API_VERSION | egrep -i --color=always "^.*$(pwd).*$|$"'
alias vush='vagrant up && vssh'
alias vnoprov='vagrant up --no-provision 2>&1 | grep -v VAGRANTFILE_API_VERSION | grep already && vagrant reload --no-provision' 

