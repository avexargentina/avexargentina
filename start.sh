#!/bin/bash

# Configurar variables de entorno si están presentes
if [ ! -z "$WEB_PORT" ]; then
    sed -i "s/<entry key='web.port'>.*<\/entry>/<entry key='web.port'>$WEB_PORT<\/entry>/" /opt/traccar/conf/traccar.xml
fi

if [ ! -z "$WEB_ADDRESS" ]; then
    sed -i "s/<entry key='web.address'>.*<\/entry>/<entry key='web.address'>$WEB_ADDRESS<\/entry>/" /opt/traccar/conf/traccar.xml
fi

# Iniciar Traccar
/opt/traccar/bin/traccar start

# Mantener el contenedor en ejecución
tail -f /opt/traccar/logs/tracker-server.log 
