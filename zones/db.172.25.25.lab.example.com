$TTL    604800
@       IN      SOA     lab.example.com. admin.lab.example.com. (
                  6     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800     ; Negative Cache TTL
)

; name servers - NS records
    IN      NS      services.lab.example.com.

; name servers - PTR records
250    IN    PTR    services.lab.example.com.

; OpenShift Container Platform Cluster - PTR records
200    IN    PTR    ocp-bootstrap.lab.example.com.
201    IN    PTR    master01.lab.example.com.
202    IN    PTR    master02.lab.example.com.
203    IN    PTR    master03.lab.example.com.
204    IN    PTR    worker01.lab.example.com.
205    IN    PTR    worker02.lab.example.com.
206    IN    PTR    worker03.lab.example.com.
250    IN    PTR    api.lab.example.com.
250    IN    PTR    api-int.lab.example.com.
