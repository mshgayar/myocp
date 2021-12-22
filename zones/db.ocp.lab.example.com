$TTL    604800
@       IN      SOA     lab.example.com. admin.lab.example.com. (
                  1     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800     ; Negative Cache TTL
)

; name servers - NS records
    IN      NS      services.lab.example.com.

; name servers - A records
services.lab.example.com.          IN      A       172.25.25.250

; OpenShift Container Platform Cluster - A records
bootstrap.lab.example.com.        IN      A      172.25.25.200
master01.lab.example.com.        IN      A      172.25.25.201
master02.lab.example.com.         IN      A      172.25.25.202
master03.lab.example.com.         IN      A      172.25.25.203
worker01.lab.example.com.        IN      A      172.25.25.204
worker02.lab.example.com.        IN      A      172.25.25.205
worker03.lab.example.com.        IN      A      172.25.25.206

; OpenShift internal cluster IPs - A records
api.lab.example.com.    IN    A    172.25.25.250
api-int.lab.example.com.    IN    A    172.25.25.250
*.apps.lab.example.com.    IN    A    172.25.25.250
etcd-0.lab.example.com.    IN    A     172.25.25.201
etcd-1.lab.example.com.    IN    A     172.25.25.202
etcd-2.lab.example.com.    IN    A    172.25.25.203
console-openshift-console.apps.lab.example.com.     IN     A     172.25.25.250
oauth-openshift.apps.lab.example.com.     IN     A     172.25.25.250

; OpenShift internal cluster IPs - SRV records
_etcd-server-ssl._tcp.lab.example.com.    86400     IN    SRV     0    10    2380    etcd-0.lab
_etcd-server-ssl._tcp.lab.example.com.    86400     IN    SRV     0    10    2380    etcd-1.lab
_etcd-server-ssl._tcp.lab.example.com.    86400     IN    SRV     0    10    2380    etcd-2.lab

