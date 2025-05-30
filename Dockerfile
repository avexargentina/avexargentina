FROM traccar/traccar:latest

# Descargar el conector de Cloud SQL para MySQL usando curl
RUN curl -L https://repo1.maven.org/maven2/com/google/cloud/sql/mysql-socket-factory/1.25.1/mysql-socket-factory-1.25.1-jar-with-dependencies.jar -o /opt/traccar/lib/mysql-socket-factory.jar

# Copiar la configuración personalizada
COPY traccar.xml /opt/traccar/conf/traccar.xml

# Exponer el puerto 8082
EXPOSE 8082
