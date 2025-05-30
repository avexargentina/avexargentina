# Etapa 1: Descargar el JAR
FROM alpine:latest as downloader
RUN apk add --no-cache curl
RUN curl -L https://repo1.maven.org/maven2/com/google/cloud/sql/mysql-socket-factory/1.25.1/mysql-socket-factory-1.25.1-jar-with-dependencies.jar -o /tmp/mysql-socket-factory.jar

# Etapa 2: Imagen final
FROM traccar/traccar:latest

# Copiar el conector de Cloud SQL
COPY --from=downloader /tmp/mysql-socket-factory.jar /opt/traccar/lib/mysql-socket-factory.jar

# Copiar la configuración personalizada
COPY traccar.xml /opt/traccar/conf/traccar.xml

# Exponer el puerto
EXPOSE 8080

# Ejecutar directamente Traccar
CMD ["java", "-Xms1g", "-Xmx1g", "-Djava.net.preferIPv4Stack=true", "-jar", "/opt/traccar/tracker-server.jar", "/opt/traccar/conf/traccar.xml"]
