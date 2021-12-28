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
230    IN    PTR    services.lab.example.com.

; OpenShift Container Platform Cluster - PTR records
238    IN    PTR    ocp-bootstrap.lab.example.com.
231    IN    PTR    master01.lab.example.com.
232    IN    PTR    master02.lab.example.com.
233    IN    PTR    master03.lab.example.com.
234    IN    PTR    worker01.lab.example.com.
235    IN    PTR    worker02.lab.example.com.
236    IN    PTR    worker03.lab.example.com.
230    IN    PTR    api.lab.example.com.
230    IN    PTR    api-int.lab.example.com.
