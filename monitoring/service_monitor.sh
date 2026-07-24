#!/bin/bash
# service_monitor.sh
# Monitorea el estado de servicios críticos del servidor
# Autor: Walter Ferrari

# Lista de servicios críticos a monitorear
SERVICIOS=(
    "ssh"
    "docker"
    "nginx"
    "fail2ban"
    "zabbix-agent"
    "cron"
)

# Contadores
OK=0
ALERTA=0

echo "========================================"
echo "   MONITOREO DE SERVICIOS CRÍTICOS"
echo "   $(date)"
echo "========================================"
echo ""

for SERVICIO in "${SERVICIOS[@]}"; do
    if systemctl is-active --quiet "$SERVICIO"; then
        echo "[OK]    $SERVICIO está corriendo"
        ((OK++))
    else
        echo "[ALERTA] $SERVICIO NO está corriendo"
        ((ALERTA++))
    fi
done

echo ""
echo "----------------------------------------"
echo "Resumen: $OK servicios OK  |  $ALERTA alertas"
echo "----------------------------------------"

# Si hay alguna alerta, el script termina con código de error
if [ "$ALERTA" -gt 0 ]; then
    echo ""
    echo "ATENCIÓN: Hay servicios caídos que requieren revisión"
    exit 1
else
    echo ""
    echo "Todos los servicios críticos funcionando correctamente"
    exit 0
fi
