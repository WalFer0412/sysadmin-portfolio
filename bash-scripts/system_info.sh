#!/bin/bash
# system_info.sh
# Muestra información básica del sistema
# Autor: Walter Ferrari

echo "==============================="
echo "   INFORMACIÓN DEL SISTEMA"
echo "==============================="
echo ""
echo "Hostname:      $(hostname)"
echo "Usuario:       $(whoami)"
echo "Fecha/Hora:    $(date)"
echo "Uptime:        $(uptime -p)"
echo ""
echo "--- CPU ---"
echo "Modelo:        $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
echo "Cores:         $(nproc)"
echo ""
echo "--- MEMORIA ---"
free -h | awk '/^Mem:/ {print "Total: "$2"  Usado: "$3"  Libre: "$4}'
echo ""
echo "--- DISCO ---"
df -h / | awk 'NR==2 {print "Total: "$2"  Usado: "$3"  Libre: "$4"  Uso: "$5}'
echo ""
echo "--- RED ---"
ip -4 addr show | grep inet | awk '{print $2}' | head -5
echo "==============================="
