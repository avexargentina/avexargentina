#!/bin/bash

# Configurar variables de entorno si están presentes
if [ ! -z "$WEB_PORT" ]; then
    sed -i "s/<entry key='web.port'>.*<\/entry>/<entry key='web.port'>$WEB_PORT<\/entry>/" /opt/traccar/conf/traccar.xml
fi

if [ ! -z "$WEB_ADDRESS" ]; then
    sed -i "s/<entry key='web.address'>.*<\/entry>/<entry key='web.address'>$WEB_ADDRESS<\/entry>/" /opt/traccar/conf/traccar.xml
fi

# Asegurarse de que los directorios necesarios existen y tienen los permisos correctos
mkdir -p /opt/traccar/logs
chown -R traccar:traccar /opt/traccar/logs
chmod -R 755 /opt/traccar/logs

# Iniciar Traccar en modo foreground
/opt/traccar/bin/traccar run

# Si el comando anterior falla, mostrar los logs
if [ $? -ne 0 ]; then
    echo "Traccar failed to start. Showing logs:"
    cat /opt/traccar/logs/tracker-server.log
    exit 1
fi 
