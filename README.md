# openshift 4.9 Cluster Installation

## OCP4.9 Cluster Requirements
Below are virtual machines running on RHEL/Centos host with Qemu Virtualization Engine
  - One Bootstrap Machine
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

#### 1) DNS Server Installation : IP 172.16.255.230 , to resolve all cluster machines with dns names
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
```
firewall-cmd --permanent --add-port=53/udp
firewall-cmd --reload
```
Configure the IP to have DNS as same IP : 172.16.255.230
```
systemctl restart NetworkManager
cat /etc/resolve.conf
  Generated by NetworkManager
  nameserver 172.16.255.230
```

#### 2) DHCP Server : Please update the dhcpd.conf with the MAC Address of all your virtual machines to be assigned with specific IPs from dhcp pool.
```
yum -y install dhcp
cp dhcpd.conf /etc/dhcp/dhcpd.conf
systemctl enable dhcpd.service
systemctl start dhcpd.service
systemctl status dhcpd.service

firewall-cmd --permanent --add-service=dhcp
firewall-cmd --reload
```
#### 3) Install HAProxy Loadbalancer for the HTTP,HTTPS and API Traffic 
```
yum install haproxy
cp haproxy.cfg /etc/haproxy/haproxy.cfg

setsebool -P haproxy_connect_any 1
systemctl enable haproxy
systemctl start haproxy
systemctl status haproxy

#### add openshift firewall ports
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=22623/tcp
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
systemctl restart haproxy
systemctl status haproxy
```
#### 4) Apacher web server : to host all the ignition (RHCOS ignition file ) to form the full cluster for (bootstrap,master and worker machines)
```
yum install –y httpd
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
mkdir /var/www/html/ocp
setsebool -P httpd_read_user_content 1
systemctl enable httpd
systemctl start httpd
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd –reload
curl localhost:8080
```

## Downloading the openshift installer and client tools version 4.9.11
```
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-4.9.11.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux-4.9.11.tar.gz

tar zxfz openshift-client-linux-4.9.11.tar.g
cp oc kubectl /usr/local/bin/
cp oc /usr/local/sbin/

tar xvfz openshift-install-linux-4.9.11.tar.gz
cp openshift-install /usr/local/bin/
cp openshift-install /usr/local/sbin/

openshift-install version
oc version
kubectl version
```

## Setting Up RHOCP 4.9.11 ignition and configuration files
Steps :
  - Create a directory for the mainfest and ignition files & copy install-config.yml to this install_dir
  - configure the cluster name , to match the dns name
  - download the pullsecret from your openshift cloud provider and add the pullsecret information to install-config.yml
  - create ssh-key and add your public key to the install-config.yml
  - Generate the Kubernetes manifests for the cluster, ignore the warning
  - Modify the cluster-scheduler-02-config.yaml manifest file to prevent Pods from being scheduled on the control plane machines
  - create the ignition-configs
  - copy all the ignition files to your webservers (/var/www/html/ocp)
```
  mkdir install_dir
  cp install-config.yml install_dir
  openshift-install create manifests --dir=install_dir/
  sed -i 's/mastersSchedulable: true/mastersSchedulable: False/' install_dir/manifests/cluster-scheduler-02-config.yml
  openshift-install create ignition-configs --dir=install_dir/

  copy all ignition file to ther web server
  cp install_dir/bootstrap.ign /var/www/html/ocp/
  cp install_dir/metadata.json /var/www/html/ocp/
  cp install_dir/master.ign /var/www/html/ocp/

  chown -R apache: /var/www/html/
  chmod -R 755 /var/www/html/

```
## Half of work has been done , lets check all the services before starting the RHCOP installation
### Check apache server :
```
[root@ocp-services ~]# curl http://172.16.255.230:8080/ocp/metadata.json
{"clusterName":"lab","clusterID":"7c815877-4f88-449b-ba50-c7b2136353bf","infraID":"lab-lbk4l"}[root@ocp-services ~]# 
```

### Check the dns server :
```
[root@ocp-services ~]# dig -x 172.16.255.230

; <<>> DiG 9.11.26-RedHat-9.11.26-6.el8 <<>> -x 172.16.255.230
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19375
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 5bc1a060efac17fb2a79c59561cb1d62c7344b78f65a37b2 (good)
;; QUESTION SECTION:
;230.255.16.172.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
230.255.16.172.in-addr.arpa. 604800 IN	PTR	api-int.lab.example.com.
230.255.16.172.in-addr.arpa. 604800 IN	PTR	services.lab.example.com.
230.255.16.172.in-addr.arpa. 604800 IN	PTR	api.lab.example.com.

;; AUTHORITY SECTION:
255.16.172.in-addr.arpa. 604800	IN	NS	services.lab.example.com.

;; ADDITIONAL SECTION:
services.lab.example.com. 604800 IN	A	172.16.255.230

;; Query time: 1 msec
;; SERVER: 172.16.255.230#53(172.16.255.230)
;; WHEN: Tue Dec 28 17:21:22 +03 2021
;; MSG SIZE  rcvd: 192
```

### check the dhcp server
```
systemctl status dhcpd.service
```

### check the haproxy server
```
[root@ocp-services ~]# systemctl status haproxy.service 
● haproxy.service - HAProxy Load Balancer
   Loaded: loaded (/usr/lib/systemd/system/haproxy.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2021-12-22 18:27:44 +03; 5 days ago
 Main PID: 41919 (haproxy)
    Tasks: 2 (limit: 36575)
   Memory: 12.5M
   CGroup: /system.slice/haproxy.service
           ├─41919 /usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid
           └─41923 /usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid

Dec 22 18:27:44 ocp-services haproxy[41919]: Proxy stats started.
Dec 22 18:27:44 ocp-services haproxy[41919]: Proxy ocp_k8s_api_fe started.
Dec 22 18:27:44 ocp-services haproxy[41919]: Proxy ocp_k8s_api_be started.
Dec 22 18:27:44 ocp-services haproxy[41919]: Proxy ocp_machine_config_server_fe started.
Dec 22 18:27:44 ocp-services haproxy[41919]: Proxy ocp_machine_config_server_be started.
Dec 22 18:27:44 ocp-services haproxy[41919]: Proxy ocp_http_ingress_traffic_fe started.
Dec 22 18:27:44 ocp-services haproxy[41919]: Proxy ocp_http_ingress_traffic_be started.
Dec 22 18:27:44 ocp-services haproxy[41919]: Proxy ocp_https_ingress_traffic_fe started.
Dec 22 18:27:44 ocp-services haproxy[41919]: Proxy ocp_https_ingress_traffic_be started.
Dec 22 18:27:44 ocp-services systemd[1]: Started HAProxy Load Balancer.
```

## Deploying the RHCOP 4.9.11 Cluster 
  - Download the RHCOS 4.9.11 from https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.9/latest/rhcos-metal.x86_64.raw.gz
  - confirm that all the created machines ( 1 bootstrap , 3 Master and 3 Nodes ) network interface MAC is configured correctly in the dhcp server, because the RHCOS machines  will be assigned their IPs from the DHCP Server 
  - configure your bootmachine option to boot first from the RHCOS live machine 
  
  ### For Bootstrap Machine : temporary machine to provision the whole cluster
    - Please boot from the rhcos-live iso , 
    - After booting to the iso version , please confirm that the machine IP is assigned from the dhcp server with below details
      - hostname : bootstrap.lab.example.com
      - IP : 172.16.255.238
    - Then install the bootstrap from its ignition files as per below :
      - sudo coreos install /dev/sda --ignition-url http://172.16.255.230:8080/ocp --insecure-ignition
      - confirm that its loading the RHCOS image , after succefull loading , you can reboot the machine
   
  ###
      
