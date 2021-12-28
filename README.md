# openshift 4.9 Cluster Installation

## OCP4.9 Cluster Requirements
  - Three Control Plane Machines
  - Three Master Node
  - One Machine for Services ( DNS - DHCP - HAProxy and Webserver) 
  - One Machine for storage ( NFS Server)

### Preparing the OCP-Services Machine : This Machine in installed with Centos 8
  - We Have to install the below services
    > DNS Server
    > DHCP Server
    > HAProxy Server
    > Apache Server
