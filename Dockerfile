FROM traccar/traccar:latest
COPY traccar.xml /opt/traccar/conf/traccar.xml
EXPOSE 8082
