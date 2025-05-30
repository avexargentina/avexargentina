FROM traccar/traccar:latest

# Descargar el conector de Cloud SQL para MySQL
RUN wget https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory/releases/download/v1.15.0/mysql-socket-factory-1.15.0-jar-with-dependencies.jar -O /opt/traccar/lib/mysql-socket-factory.jar

# Copiar la configuración personalizada
COPY traccar.xml /opt/traccar/conf/traccar.xml

# Exponer el puerto 8082
EXPOSE 8082
