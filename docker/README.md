# Docker — Monitoreo de Contenedores

## Descripción
Script de monitoreo para entornos Docker. Verifica el estado de todos los
contenedores, muestra información relevante de cada uno y registra el uso
de recursos en tiempo real.

---

## docker_monitor.sh

### ¿Qué hace?
- Verifica que el servicio Docker esté activo antes de continuar
- Recorre todos los contenedores (activos y detenidos)
- Muestra por cada contenedor: nombre, imagen, puerto expuesto y estado
- Genera alertas si algún contenedor está detenido
- Muestra el uso de CPU y memoria de cada contenedor activo
- Guarda toda la salida en un archivo de log con timestamp

### Salida de ejemplo
[OK]    miweb  |  Imagen: app-nginx:latest  |  Puerto: 0.0.0.0:8083->80/tcp
[OK]    web3   |  Imagen: nginx             |  Puerto: 0.0.0.0:8082->80/tcp
[OK]    web2   |  Imagen: nginx             |  Puerto: 0.0.0.0:8081->80/tcp
[OK]    web1   |  Imagen: nginx             |  Puerto: 0.0.0.0:8080->80/tcp
Contenedor: miweb  |  CPU: 0.00%  |  Memoria: 3.336MiB / 3.789GiB

### Log
La salida se guarda automáticamente en:
/var/log/sysadmin/docker_monitor.log
Cada ejecución se agrega al log con fecha y hora, permitiendo llevar un historial del estado del entorno.

### Entorno donde fue ejecutado
- **OS:** Debian Linux
- **Docker version:** $(docker --version)
- **Contenedores monitoreados:** miweb, web1, web2, web3
- **Imágenes en uso:** app-nginx:latest, nginx

---

## Conceptos aplicados
- Verificación de dependencias antes de ejecutar
- Parseo de salida de comandos Docker con `awk`
- Uso de contadores y lógica condicional en Bash
- Registro de logs con timestamp
- Códigos de salida para integración con sistemas de monitoreo externos
