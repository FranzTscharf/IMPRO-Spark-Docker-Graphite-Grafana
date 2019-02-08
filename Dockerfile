FROM grafana/grafana

# Add the default dashboards
ADD	    ./grafana/datasources/* /etc/grafana/provisioning/datasources/
ADD     ./grafana/dashboards/* /etc/grafana/provisioning/dashboards/

EXPOSE 3000