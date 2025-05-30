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

# Crear script de inicio que use la variable PORT de Cloud Run
RUN echo '#!/bin/bash\n\
PORT=${PORT:-8082}\n\
# Actualizar el puerto en la configuración\n\
sed -i "s|<entry key='"'"'web.port'"'"'>8082</entry>|<entry key='"'"'web.port'"'"'>$PORT</entry>|" /opt/traccar/conf/traccar.xml\n\
# Iniciar Traccar\n\
exec java -Xms1g -Xmx1g -Djava.net.preferIPv4Stack=true -jar /opt/traccar/tracker-server.jar /opt/traccar/conf/traccar.xml\n\
' > /opt/traccar/start.sh && chmod +x /opt/traccar/start.sh

# Exponer el puerto (Cloud Run usará la variable PORT)
EXPOSE 8080

# Usar el script de inicio
CMD ["/opt/traccar/start.sh"]
