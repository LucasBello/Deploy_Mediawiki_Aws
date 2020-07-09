sudo ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-386.tar.gz
tar xvfz node_exporter-1.0.1.linux-386.tar.gz

nohup ./node_exporter-1.0.1.linux-386/node_exporter >> /var/log/nodeexporter.log &

sudo setsebool -P httpd_can_network_connect 1