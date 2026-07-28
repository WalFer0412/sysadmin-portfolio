# Zabbix — Verificación del Agente

## Descripción
Script de diagnóstico para el agente Zabbix. Verifica el estado del servicio,
analiza la configuración y detecta automáticamente si el agente está correctamente
apuntado a un servidor Zabbix real o mal configurado.

---

## zabbix_agent_check.sh

### ¿Qué hace?
- Verifica que el servicio zabbix-agent esté activo y muestra la versión
- Lee el archivo de configuración y extrae los parámetros clave
- Detecta si el agente apunta a localhost en lugar de un servidor real
- Intenta conectividad al servidor configurado si es una IP válida
- Muestra las últimas líneas del log del agente para diagnóstico
- Guarda toda la salida en archivo de log con timestamp

### Salida de ejemplo
[OK]    zabbix-agent está corriendo

[INFO]  Versión: zabbix_agentd (daemon) (Zabbix) 6.0.14

[INFO]  Server:       127.0.0.1

[ALERTA] Server apunta a localhost (127.0.0.1)

[INFO]   El agente está corriendo pero NO reporta a un servidor Zabbix real

### Log
/var/log/sysadmin/zabbix_check.log

---

## Hallazgo en este entorno

El agente Zabbix 6.0.14 está instalado y corriendo correctamente
pero apunta a `127.0.0.1` por ser una VM creada desde plantilla organizacional.

**Error detectado en log del agente:**
Unable to connect to [127.0.0.1]:10051 — Connection refused
Active check configuration update started to fail

### ¿Cómo conectarlo a un servidor Zabbix real?

```bash
# Editar el archivo de configuración
sudo nano /etc/zabbix/zabbix_agentd.conf

# Modificar estas líneas con la IP del servidor Zabbix
Server=IP_DEL_SERVIDOR_ZABBIX
ServerActive=IP_DEL_SERVIDOR_ZABBIX
Hostname=hostname

# Reiniciar el agente para aplicar cambios
sudo systemctl restart zabbix-agent

# Verificar que no haya errores en el log
tail -f /var/log/zabbix-agent/zabbix_agentd.log
```

---

## Arquitectura Zabbix — Agente vs Servidor
[ Servidor Zabbix ]  ←→  [ Zabbix Agent ]
Puerto 10051              Este servidor
Interfaz web              dock-pc
Base de datos             Recolecta métricas
CPU, memoria, disco
servicios, logs

El agente recolecta métricas del servidor donde está instalado 
y las envía al servidor Zabbix central para visualización y alertas.

---

## Conceptos aplicados
- Lectura y parseo de archivos de configuración con `grep` y `cut`
- Verificación de conectividad con `ping`
- Diagnóstico condicional según valores de configuración
- Lectura de logs del sistema con `tail`
- Registro de resultados con timestamp
