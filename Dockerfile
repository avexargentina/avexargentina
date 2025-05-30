# Etapa 1: Descargar el JAR
FROM alpine:latest as downloader
RUN apk add --no-cache curl
RUN curl -L https://repo1.maven.org/maven2/com/google/cloud/sql/mysql-socket-factory/1.25.1/mysql-socket-factory-1.25.1-jar-with-dependencies.jar -o /tmp/mysql-socket-factory.jar

# Etapa 2: Imagen final
FROM traccar/traccar:latest
COPY --from=downloader /tmp/mysql-socket-factory.jar /opt/traccar/lib/mysql-socket-factory.jar
COPY traccar.xml /opt/traccar/conf/traccar.xml
EXPOSE 8082
