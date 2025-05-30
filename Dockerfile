# Usa la imagen oficial de Traccar como base
FROM traccar/traccar:latest

# Copia tu archivo traccar.xml personalizado al directorio de configuración.
# Después de esta copia, /opt/traccar/conf/traccar.xml será propiedad de root:root.
COPY traccar.xml /opt/traccar/conf/traccar.xml

# Cambia temporalmente al usuario root para poder cambiar el propietario del archivo.
USER root

# Ahora, como root, cambia el propietario del archivo al usuario y grupo 'traccar'.
# El usuario y grupo 'traccar' deben existir en la imagen base.
RUN chown traccar:traccar /opt/traccar/conf/traccar.xml

# Vuelve al usuario 'traccar', que es el usuario con el que la aplicación Traccar
# se ejecutará (según la configuración de la imagen base traccar/traccar:latest).
USER traccar

# Traccar se ejecuta por defecto en el puerto 8082, que ya está expuesto por la imagen base.
# El entrypoint y CMD ya están definidos en la imagen base para iniciar Traccar.
