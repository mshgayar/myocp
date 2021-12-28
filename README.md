# openshift 4.9 Cluster Installation

## OCP4.9 Cluster Requirements
Below are virtual machines running on RHEL host with Qemu Virtualization Engine
  - Three Control Plane Machines
  - Three Master Node
  - One Machine for Services ( DNS - DHCP - HAProxy and Webserver) 
  - One Machine for storage ( NFS Server)

### Preparing the OCP-Services Machine : This Machine in installed with Centos 8
  - We Have to install the below services
    - DNS Server bind
    - DHCP Server dhcp
    - HAProxy Server haproxy
    - Apache Server httpd
