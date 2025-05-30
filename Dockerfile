# Usa la imagen oficial de Traccar como base
FROM traccar/traccar:latest

# Copia tu archivo traccar.xml personalizado al directorio de configuración.
# El archivo será propiedad de root:root con permisos de lectura para otros.
# La imagen base traccar/traccar:latest debería configurar USER traccar
# para que el proceso de Traccar se ejecute como usuario 'traccar'.
COPY traccar.xml /opt/traccar/conf/traccar.xml

# No se necesita USER root, chown, ni USER traccar aquí,
# ya que la imagen base debería manejar el usuario de ejecución.
# El proceso Traccar, ejecutándose como 'traccar', debería poder leer
# el archivo traccar.xml aunque sea propiedad de root.
