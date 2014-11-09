# {{ ansible_managed }}
#
oracle.install.responseFileVersion=/oracle/install/rspfmt_crsinstall_response_schema_v12.1.0

ORACLE_HOSTNAME={{ oracle_hostname }}

#-------------------------------------------------------------------------------
# Specify the location which holds the inventory files.
# This is an optional parameter if installing on  
# Windows based Operating System.
#-------------------------------------------------------------------------------
INVENTORY_LOCATION={{ oracle_inventory_loc }}
SELECTED_LANGUAGES=en
#-------------------------------------------------------------------------------
# Specify the installation option.
# Allowed values: CRS_CONFIG or HA_CONFIG or UPGRADE or CRS_SWONLY or HA_SWONLY
#   - CRS_CONFIG : To configure Grid Infrastructure for cluster
#   - HA_CONFIG  : To configure Grid Infrastructure for stand alone server
#   - UPGRADE    : To upgrade clusterware software of earlier release
#   - CRS_SWONLY : To install clusterware files only (can be configured for cluster 
#                  or stand alone server later)
#   - HA_SWONLY  : To install clusterware files only (can be configured for stand 
#                  alone server later. This is only supported on Windows.)
#-------------------------------------------------------------------------------
oracle.install.option={{ oracle_install_option_gi }}

ORACLE_BASE={{ oracle_base }}

#-------------------------------------------------------------------------------
# Specify the complete path of the Oracle Home.
#-------------------------------------------------------------------------------
ORACLE_HOME={{ oracle_home_gi }}

#-------------------------------------------------------------------------------
# The DBA_GROUP is the OS group which is to be granted OSDBA privileges.
#-------------------------------------------------------------------------------

{% if role_separation==True %}

oracle.install.asm.OSDBA={{ asmdba_group }}

##-------------------------------------------------------------------------------
## The OPER_GROUP is the OS group which is to be granted OSOPER privileges.
## The value to be specified for OSOPER group is optional.
##-------------------------------------------------------------------------------
oracle.install.asm.OSOPER={{ asmoper_group }}
#
##-------------------------------------------------------------------------------
## The OSASM_GROUP is the OS group which is to be granted OSASM privileges. This
## must be different than the previous two.
##-------------------------------------------------------------------------------
oracle.install.asm.OSASM={{ asmadmin_group }}

   {% else %}

oracle.install.asm.OSDBA={{ dba_group }}

#-------------------------------------------------------------------------------
## The OPER_GROUP is the OS group which is to be granted OSOPER privileges.
## The value to be specified for OSOPER group is optional.
##-------------------------------------------------------------------------------
oracle.install.asm.OSOPER={{ oper_group }}

 ##-------------------------------------------------------------------------------
# The OSASM_GROUP is the OS group which is to be granted OSASM privileges. This
# must be different than the previous two.
#-------------------------------------------------------------------------------
oracle.install.asm.OSASM={{ dba_group }}

{% endif %}
   
################################################################################
#                                                                              #
#                           SECTION C - SCAN                                   #
#                                                                              #
################################################################################


#-------------------------------------------------------------------------------
# Specify a name for SCAN
#-------------------------------------------------------------------------------
oracle.install.crs.config.gpnp.scanName={% if configure_cluster==True %}{{ oracle_scan }}{% else %}{% endif %}

#-------------------------------------------------------------------------------
# Specify a unused port number for SCAN service
#-------------------------------------------------------------------------------
oracle.install.crs.config.gpnp.scanPort={% if configure_cluster==True %}{{ oracle_scan_port }}{% else %}{% endif %}

################################################################################
#                                                                              #
#                           SECTION D - CLUSTER & GNS                         #
#                                                                              #
################################################################################
#-------------------------------------------------------------------------------
# Specify the type of cluster you would like to configure
# Allowed values: FLEX and STANDARD
#-------------------------------------------------------------------------------
oracle.install.crs.config.ClusterType=FLEX


#-------------------------------------------------------------------------------
# Specify a name for the Cluster you are creating.
#
# The maximum length allowed for clustername is 15 characters. The name can be 
# any combination of lower and uppercase alphabets (A - Z), (0 - 9), hyphen(-)
# and underscore(_).
#-------------------------------------------------------------------------------
oracle.install.crs.config.clusterName={% if configure_cluster==True %}{{ oracle_cluster_name }}{% else %}{% endif %}

#-------------------------------------------------------------------------------
# Specify 'true' if you would like to configure Grid Naming Service(GNS), else
# specify 'false'
#-------------------------------------------------------------------------------
oracle.install.crs.config.gpnp.configureGNS=false

#-------------------------------------------------------------------------------
# Applicable only if you choose to configure GNS
# Specify 'true' if you would like to assign SCAN name VIP and Node VIPs by DHCP
# , else specify 'false'
#-------------------------------------------------------------------------------
oracle.install.crs.config.autoConfigureClusterNodeVIP=false

#-------------------------------------------------------------------------------
# Applicable only if you choose to configure GNS
# Specify the type of GNS configuration for cluster
# Allowed values are: CREATE_NEW_GNS and USE_SHARED_GNS
#-------------------------------------------------------------------------------
oracle.install.crs.config.gpnp.gnsOption=CREATE_NEW_GNS

#-------------------------------------------------------------------------------
# Applicable only if SHARED_GNS is being configured for cluster
# Specify the path to the GNS client data file
#-------------------------------------------------------------------------------
oracle.install.crs.config.gpnp.gnsClientDataFile=

#-------------------------------------------------------------------------------
# Applicable only if you choose to configure GNS for this cluster
# oracle.install.crs.config.gpnp.gnsOption=CREATE_NEW_GNS
# Specify the GNS subdomain and an unused virtual hostname for GNS service
#-------------------------------------------------------------------------------
oracle.install.crs.config.gpnp.gnsSubDomain=
oracle.install.crs.config.gpnp.gnsVIPAddress=



#-------------------------------------------------------------------------------
# Specify the list of nodes that have to be configured to be part of the cluster.
#
# The list should a comma-separated list of tuples.  Each tuple should be a
# colon-separated string that contains
# - 2 fields if configuring a Standard Cluster, or 
# - 3 fields if configuring a Flex Cluster
# 
# The fields should be ordered as follows:
# 1. The first field should be the public node name.
# 2. The second field should be the virtual host name
#    (Should be specified as AUTO if you have chosen 'auto configure for VIP'
#     i.e. autoConfigureClusterNodeVIP=true)
# 3. The third field indicates the role of node (HUB,LEAF). This has to 
#    be provide only if Flex Cluster is being configured.
#
# Examples
# For configuring Standard Cluster: oracle.install.crs.config.clusterNodes=node1:node1-vip,node2:node2-vip
# For configuring Flex Cluster: oracle.install.crs.config.clusterNodes=node1:node1-vip:HUB,node2:node2-vip:LEAF
#
#
#-------------------------------------------------------------------------------
# more elegant try to use the following :
# {% if 'webserver' in group_names %}
# some part of a configuration file that only applies to webservers
# {% endif %}

{%  if ansible_domain  == ""  %}
oracle.install.crs.config.clusterNodes={% if configure_cluster==True %}{% for host in groups[hub] -%} {{host}}:{{ host }}{{ oracle_vip }}:HUB{%- if not loop.last -%} , {%- endif -%} {%- endfor %}{% for host in groups[leaf] -%} {{host}}:{{ host }}{{ oracle_vip }}:LEAF{%- if not loop.last -%} , {%- endif -%} {%- endfor %}{% else %}{% endif %}
{% else  %}
oracle.install.crs.config.clusterNodes={% if configure_cluster==True %}{% for host in groups[hub] -%} {{host}}.{{ ansible_domain }}:{{ host }}{{ oracle_vip }}:HUB.{{ ansible_domain }} {%- if not loop.last -%} , {%- endif -%} {%- endfor %}{% for host in groups[leaf] -%} {{host}}.{{ ansible_domain }}:{{ host }}{{ oracle_vip }}:LEAF.{{ ansible_domain }} {%- if not loop.last -%} , {%- endif -%} {%- endfor %}{% else %}{% endif %}
{% endif %}


#-------------------------------------------------------------------------------
# The value should be a comma separated strings where each string is as shown below
# InterfaceName:SubnetMask:InterfaceType
# where InterfaceType can be either "1", "2", "3", "4", or "5"
# InterfaceType stand for the following values
#   - 1 : PUBLIC
#   - 2 : PRIVATE
#   - 3 : DO NOT USE
#   - 4 : ASM
#   - 5 : ASM & PRIVATE
#
# For example: eth0:140.87.24.0:1,eth1:10.2.1.0:2,eth2:140.87.52.0:3
#
#-------------------------------------------------------------------------------
oracle.install.crs.config.networkInterfaceList={% if configure_cluster==True %}{{ oracle_gi_nic_pub }}:{{ hostvars[inventory_hostname]["ansible_" + oracle_gi_nic_pub].ipv4.network }}:1,{{ oracle_gi_nic_priv }}:{{ hostvars[inventory_hostname]["ansible_" + oracle_gi_nic_priv].ipv4.network }}:5{% else %}{% endif %}

#-------------------------------------------------------------------------------
# Specify 'true' if you would like to configure Management Database Option, else
# specify 'false'
#-------------------------------------------------------------------------------
#oracle.install.crs.managementdb.configure={{ oracle_cluster_mgmdb }}

################################################################################
#                                                                              #
#                              SECTION E - STORAGE                             #
#                                                                              #
################################################################################

#-------------------------------------------------------------------------------
# Specify the type of storage to use for Oracle Cluster Registry(OCR) and Voting
# Disks files
#   - LOCAL_ASM_STORAGE
#   - FLEX_ASM_STORAGE
#   - FILE_SYSTEM_STORAGE
# If configuring a Flex Cluster, FLEX_ASM_STORAGE is the only allowed value 
#-------------------------------------------------------------------------------
oracle.install.crs.config.storageOption=FLEX_ASM_STORAGE

#-------------------------------------------------------------------------------
# These properties are applicable only if FILE_SYSTEM_STORAGE is chosen for 
# storing OCR and voting disk
# Specify the location(s) and redundancy for OCR and voting disks
# Multiple locations can be specified, separated by commas.
# In case of windows, mention the drive location that is specified to be
# formatted for DATA in the above property.
# Redundancy can be one of these:
#     EXTERNAL - one(1) location should be specified for OCR and voting disk
#     NORMAL - three(3) locations should be specified for OCR and voting disk
# Example:
#     For Unix based Operating System:
#     oracle.install.crs.config.sharedFileSystemStorage.votingDiskLocations=/oradbocfs/storage/vdsk1,/oradbocfs/storage/vdsk2,/oradbocfs/storage/vdsk3
#     oracle.install.crs.config.sharedFileSystemStorage.ocrLocations=/oradbocfs/storage/ocr1,/oradbocfs/storage/ocr2,/oradbocfs/storage/ocr3
#     For Windows based Operating System OCR/VDSK on shared storage is not supported.
#-------------------------------------------------------------------------------
#oracle.install.crs.config.sharedFileSystemStorage.votingDiskLocations=
#oracle.install.crs.config.sharedFileSystemStorage.votingDiskRedundancy=NORMAL
#oracle.install.crs.config.sharedFileSystemStorage.ocrLocations=
#oracle.install.crs.config.sharedFileSystemStorage.ocrRedundancy=NORMAL
               	
################################################################################
#                                                                              #
#                               SECTION F - IPMI                               #
#                                                                              #
################################################################################

#-------------------------------------------------------------------------------
# Specify 'true' if you would like to configure Intelligent Power Management interface
# (IPMI), else specify 'false'
#-------------------------------------------------------------------------------
oracle.install.crs.config.useIPMI=false

#-------------------------------------------------------------------------------
# Applicable only if you choose to configure IPMI
# i.e. oracle.install.crs.config.useIPMI=true
# Specify the username and password for using IPMI service
#-------------------------------------------------------------------------------
oracle.install.crs.config.ipmi.bmcUsername=
oracle.install.crs.config.ipmi.bmcPassword=

################################################################################
#                                                                              #
#                                SECTION G - ASM                               #
#                                                                              #
################################################################################
#-------------------------------------------------------------------------------
# Specify a password for SYSASM user of the ASM instance
#-------------------------------------------------------------------------------
oracle.install.asm.SYSASMPassword={{ oracle_password }}

#-------------------------------------------------------------------------------
# The ASM DiskGroup
#
# Example: oracle.install.asm.diskGroup.name=data
#
#-------------------------------------------------------------------------------
oracle.install.asm.diskGroup.name={{ oracle_asm_init_dg }}

#-------------------------------------------------------------------------------
# Redundancy level to be used by ASM.
# It can be one of the following  
#   - NORMAL
#   - HIGH
#   - EXTERNAL
# Example: oracle.install.asm.diskGroup.redundancy=NORMAL
#
#-------------------------------------------------------------------------------
oracle.install.asm.diskGroup.redundancy=EXTERNAL

#-------------------------------------------------------------------------------
# Allocation unit size to be used by ASM.
# It can be one of the following values
#   - 1
#   - 2
#   - 4
#   - 8
#   - 16
#   - 32
#   - 64
# Example: oracle.install.asm.diskGroup.AUSize=4
# size unit is MB
#
#-------------------------------------------------------------------------------
oracle.install.asm.diskGroup.AUSize=1

#-------------------------------------------------------------------------------
# List of disks to create a ASM DiskGroup
#
# Example:
#     For Unix based Operating System:
#     oracle.install.asm.diskGroup.disks=/oracle/asm/disk1,/oracle/asm/disk2
#     For Windows based Operating System:
#     oracle.install.asm.diskGroup.disks=\\.\ORCLDISKDATA0,\\.\ORCLDISKDATA1
#
#-------------------------------------------------------------------------------
oracle.install.asm.diskGroup.disks={% if device_persistence=='udev' %}{% for disk in  asm_storage_layout[oracle_asm_init_dg]    -%}  {{ oracle_asm_disk_string }}{{ disk.asmlabel }}{%- if not loop.last -%} , {%- endif -%} {%- endfor %}{% else %}{% for disk in  asm_storage_layout[oracle_asm_init_dg]    -%} ORCL:{{ disk.asmlabel|upper }}{%- if not loop.last -%} , {%- endif -%} {%- endfor %} {% endif %}

#-------------------------------------------------------------------------------
# The disk discovery string to be used to discover the disks used create a ASM DiskGroup
#
# Example:
#     For Unix based Operating System:
#     oracle.install.asm.diskGroup.diskDiscoveryString=/oracle/asm/*
#     For Windows based Operating System:
#     oracle.install.asm.diskGroup.diskDiscoveryString=\\.\ORCLDISK*
#
#-------------------------------------------------------------------------------
oracle.install.asm.diskGroup.diskDiscoveryString={% if device_persistence == 'asmlib' %}{% else %}{{ oracle_asm_disk_string }}*{% endif %}

#-------------------------------------------------------------------------------
# oracle.install.asm.monitorPassword=password
#-------------------------------------------------------------------------------
oracle.install.asm.monitorPassword={{ oracle_password }}


################################################################################
#                                                                              #
#                             SECTION H - UPGRADE                              #
#                                                                              #
################################################################################
#-------------------------------------------------------------------------------
# Specify whether to ignore down nodes during upgrade operation.
# Value should be 'true' to ignore down nodes otherwise specify 'false'
#-------------------------------------------------------------------------------
oracle.install.crs.config.ignoreDownNodes=false

#------------------------------------------------------------------------------
# Specify the auto-updates option. It can be one of the following:
#   - MYORACLESUPPORT_DOWNLOAD
#   - OFFLINE_UPDATES
#   - SKIP_UPDATES
#------------------------------------------------------------------------------
oracle.installer.autoupdates.option=SKIP_UPDATES

#------------------------------------------------------------------------------
# In case MYORACLESUPPORT_DOWNLOAD option is chosen, specify the location where
# the updates are to be downloaded.
# In case OFFLINE_UPDATES option is chosen, specify the location where the updates
# are present.
#------------------------------------------------------------------------------
oracle.installer.autoupdates.downloadUpdatesLoc=

#------------------------------------------------------------------------------
# Specify the My Oracle Support Account Username which has the patches download privileges  
# to be used for software updates.
#  Example   : AUTOUPDATES_MYORACLESUPPORT_USERNAME=abc@oracle.com
#------------------------------------------------------------------------------
AUTOUPDATES_MYORACLESUPPORT_USERNAME=

#------------------------------------------------------------------------------
# Specify the My Oracle Support Account Username password which has the patches download privileges  
# to be used for software updates.
#
# Example    : AUTOUPDATES_MYORACLESUPPORT_PASSWORD=password
#------------------------------------------------------------------------------
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=

#------------------------------------------------------------------------------
# Specify the Proxy server name. Length should be greater than zero.
#
# Example    : PROXY_HOST=proxy.domain.com 
#------------------------------------------------------------------------------
PROXY_HOST=

#------------------------------------------------------------------------------
# Specify the proxy port number. Should be Numeric and atleast 2 chars.
#
# Example    : PROXY_PORT=25 
#------------------------------------------------------------------------------
PROXY_PORT=0

#------------------------------------------------------------------------------
# Specify the proxy user name. Leave PROXY_USER and PROXY_PWD 
# blank if your proxy server requires no authentication.
#
# Example    : PROXY_USER=username 
#------------------------------------------------------------------------------
PROXY_USER=

#------------------------------------------------------------------------------
# Specify the proxy password. Leave PROXY_USER and PROXY_PWD  
# blank if your proxy server requires no authentication.
#
# Example    : PROXY_PWD=password 
#------------------------------------------------------------------------------
PROXY_PWD=

#------------------------------------------------------------------------------
# Specify the proxy realm.
#
# Example    : PROXY_REALM=metalink
#------------------------------------------------------------------------------
PROXY_REALM=
