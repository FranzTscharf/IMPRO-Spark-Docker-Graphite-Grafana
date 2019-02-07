StatsD 0.8.0 + Graphite 1.0.2 + Grafana 4.5.1
---------------------------------------------

This image contains a sensible default configuration of StatsD, Graphite and Grafana. It is based on [Ken DeLong's repository on the Docker Index](https://index.docker.io/u/kenwdelong/) and published under [Maria Łysik's repository](https://hub.docker.com/u/marial/).

The container exposes the following ports:
- `80`: the Grafana web interface.
- `2003`: the Carbon port.
- `8125`: the StatsD port.
- `8126`: the StatsD administrative port.
If you already have services running on your host that are using any of these ports, you may wish to map the container
ports to whatever you want by changing left side number in the `-p` parameters. Find more details about mapping ports
in the [Docker documentation](http://docs.docker.io/use/port_redirection/#port-redirection).

There are three ways for using this image:

### Building the image yourself ###
The Dockerfile and supporting configuration files are available in [Github repository](https://github.com/MariaLysik/docker-grafana-graphite).
This comes specially handy if you want to change any of the StatsD, Graphite or Grafana settings, or simply if you want to know how the image was built.

### Using the Docker Index ###
```bash
docker run -d -p 80:80 -p 8125:8125/udp -p 8126:8126 --name grafana marial/grafana-graphite-statsd
```

### Using Kubernetes ###
`ATTENTION: this example uses already created Azure file share as permanent storage for graphite data. If you do not wish to use any volumes, just skip secret creation and volume parts in graphite.yml.`
First create secret to Azure storage with file volumes, but keep in mind that both name and key have to be base64 encoded (you can use  `echo -n <my-storage-account> | base64` for it).
azure-secret.yml
```bash
apiVersion: v1
kind: Secret
metadata:
  name: azure-secret
type: Opaque
data:
  azurestorageaccountname: base64encodedAccountName=
  azurestorageaccountkey: base64encodedAccountKey==
```
And then...
```bash
kubectl create -f azure-secret.yml
kubectl create -f graphite.yml
```
graphite.yml
```bash
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: graphite
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: graphite
    spec:
      containers:
      - name: graphite
        image: marial/grafana-graphite-statsd
        ports:
        - containerPort: 80
          name: grafaa
        - containerPort: 2003
          name: carbon
        - containerPort: 8125
          name: udp
        - containerPort: 8126
          name: statsd
        volumeMounts:
        - name: graphite-whisper
          mountPath: /opt/graphite/storage/whisper
      volumes:
        - name: graphite-whisper
          azureFile:
            secretName: azure-secret
            shareName: graphitewhisper
            readOnly: false
---
apiVersion: v1
kind: Service
metadata:
  name: graphite-tcp
spec:
  type: LoadBalancer
  ports:
  - name: grafana
    protocol: TCP
    port: 80
    targetPort: 80
  - name: carbon
    protocol: TCP
    port: 2003
    targetPort: 2003
  - name: statsdadmin
    protocol: TCP
    port: 8126
    targetPort: 8126
  selector:
    app: graphite
---
apiVersion: v1
kind: Service
metadata:
  name: graphite-udp
spec:
  type: LoadBalancer
  ports:
  - name: statsd
    protocol: UDP
    port: 8125
    targetPort: 8125
  selector:
    app: graphite
```

#### Testing ####
Run the test script in the test-grafana directory.  Then go to port 80 on the container, log in as admin/admin, and create a chart that looks at `stats/counters/example/statsd/counter/changed/count`.  You should see the graph working there.

#### External Volumes ####
External volumes can be used to customize graphite configuration and store data out of the container.
- Graphite configuration: `/opt/graphite/conf`
- Graphite data: `/opt/graphite/storage/whisper`
- Supervisord log: `/var/log/supervisor`

### Using the Dashboard ###
Once your container is running all you need to do is:
- open your browser pointing to the host/port you just published
- login with the default username (admin) and password (admin)
- configure a new datasource to point at the Graphite metric data (URL - http://localhost:8000) and replace the default Grafana test datasource for your graphs
- open your browser pointing to the host/port you just published and play with the dashboard at your wish...