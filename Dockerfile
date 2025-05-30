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

# Crear script de inicio como archivo separado
COPY <<EOF /opt/traccar/start.sh
#!/bin/bash
set -e

# Usar PORT de Cloud Run o default 8082
PORT=\${PORT:-8082}
echo "Starting Traccar on port \$PORT"

# Actualizar el puerto en la configuración
sed -i "s|<entry key=\"web.port\">8082</entry>|<entry key=\"web.port\">\$PORT</entry>|" /opt/traccar/conf/traccar.xml

# Verificar que el archivo de configuración existe
if [ ! -f /opt/traccar/conf/traccar.xml ]; then
    echo "Error: traccar.xml no encontrado"
    exit 1
fi

# Mostrar configuración del puerto para debug
grep "web.port" /opt/traccar/conf/traccar.xml || echo "Advertencia: No se encontró configuración de puerto"

# Iniciar Traccar
echo "Iniciando Traccar..."
exec java -Xms1g -Xmx1g -Djava.net.preferIPv4Stack=true -jar /opt/traccar/tracker-server.jar /opt/traccar/conf/traccar.xml
EOF

# Hacer el script ejecutable
RUN chmod +x /opt/traccar/start.sh

# Exponer el puerto
EXPOSE 8080

# Usar bash explícitamente
CMD ["/bin/bash", "/opt/traccar/start.sh"]
