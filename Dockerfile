FROM grafana/grafana
USER root
# Add the default dashboards
ADD	    ./grafana/datasources/* /etc/grafana/provisioning/datasources/
ADD     ./grafana/dashboards/* /etc/grafana/provisioning/dashboards/
#if you run the setup on the local machine please remove the following line: RUN export REPLACE_STR=s/localhost/${NODE_V_PUBLIC_IP}/g
#RUN		export REPLACE_STR=s/localhost/${NODE_V_PUBLIC_IP}/g
#RUN     sed -i -e "s/localhost/$NODE_V_PUBLIC_IP/g" /etc/grafana/provisioning/datasources/datasource.yml


EXPOSE 3000