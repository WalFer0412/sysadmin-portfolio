# Backup — Respaldo Remoto con Rsync

## Descripción
Script de backup automatizado que transfiere directorios críticos
hacia un servidor remoto usando rsync sobre SSH.
Diseñado para ejecutarse periódicamente via cron en entornos Linux.

---

## backup.sh

### ¿Qué hace?
- Verifica conectividad con el servidor destino antes de iniciar
- Comprueba que rsync esté instalado en el servidor origen
- Crea el directorio destino en el servidor remoto si no existe
- Respalda cada directorio configurado usando rsync sobre SSH
- Detecta y reporta errores por cada directorio procesado
- Guarda historial completo en archivo de log con timestamp

### Directorios respaldados
| Directorio | Descripción |
|---|---|
| `/etc` | Configuraciones del sistema operativo |
| `/home/walfer0412/sysadmin-portfolio` | Scripts y portfolio profesional |
| `/var/log/sysadmin` | Logs generados por scripts de monitoreo |

### Servidor destino

Origen: walfer-PC (100.10.100.207)
Destino: 100.10.100.208:/backup/walfer-PC


### Requisitos
- rsync instalado en ambos servidores
- Autenticación SSH sin contraseña configurada entre origen y destino
- Usuario con permisos de lectura en los directorios a respaldar

### Log

/var/log/sysadmin/backup.log


---

## Cómo agregar un directorio al backup

Editá la sección `DIRECTORIOS` en el script:

```bash
DIRECTORIOS=(
    "/etc"
    "/home/walfer0412/sysadmin-portfolio"
    "/var/log/sysadmin"
    "/ruta/nuevo/directorio"    # agregar acá
)
```

---

## Automatización con cron

Para ejecutar el backup todos los días a las 2:00 AM:

```bash
# Editar el crontab
crontab -e

# Agregar esta línea
0 2 * * * /home/walfer0412/sysadmin-portfolio/backup/backup.sh
```

---

## Conceptos aplicados
- Transferencia segura con rsync sobre SSH
- Autenticación por clave pública sin contraseña
- Verificación de dependencias y conectividad previa
- Manejo de errores por directorio con contadores
- Registro de log con timestamp para auditoría
- Códigos de salida para integración con sistemas externos
