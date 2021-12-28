# openshift 4.9 Cluster Installation

## OCP4.9 Cluster Requirements
Below are virtual machines running on RHEL/Centos host with Qemu Virtualization Engine
  - Three Control Plane Machines
  - Three Master Node
  - One Machine for Services ( DNS - DHCP - HAProxy and Webserver) 
  - One Machine for storage ( NFS Server)

## Preparing the OCP-Services Machine : This Machine in installed with Centos 8
  - We Have to install the below services
    - DNS Server bind
    - DHCP Server dhcp
    - HAProxy Server haproxy
    - Apache Server httpd

#### DNS Server Installation : IP 172.16.255.230
Install dns service
  ```
  yum -y install bind bind-utils
  cp named.conf /etc/named.conf
  cp named.conf.local /etc/named/
  mkdir /etc/named/zones
  cp db* /etc/named/zones
  ```

start & enable dns service
```
systemctl enable named
systemctl start named
systemctl status named
```
configure firewall ports for dns
firewall-cmd --permanent --add-port=53/udp
firewall-cmd --reload

Configure the IP to have DNS as same IP : 172.16.255.230
cat /etc/resolve.conf
  Generated by NetworkManager
  nameserver 172.16.255.230
