#!/bin/bash
#SCRIPT DE MANTENIMIENTO COMPLETO
#Comprobar permisos
#!/bin/bash
#SCRIPT DE MANTENIMIENTO COMPLETO
#Comprobar permisos
if [ "$EUID" -ne 0 ]; then
    echo "Ejecute este script con sudo."
    exit 1
fi

#Variables
INICIO=$(date +%s)
USUARIO_REAL=${SUDO_USER:-$USER}
HOME_USUARIO=$(eval echo "~$USUARIO_REAL")
FECHA=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="$HOME_USUARIO/backups"
LOG="$BACKUP_DIR/mantenimiento_$FECHA.log"
mkdir -p "$BACKUP_DIR"

#Guardamos lo que aparece en pantalla dentro del log
exec > >(tee -a "$LOG") 2>&1
echo "MANTENIMIENTO DEL SISTEMA"
echo "Fecha: $(date)"
echo

#Limpieza previa agresiva
echo "Limpieza previa agresiva..."
apt clean
rm -rf /var/cache/apt/archives/*
rm -rf /var/cache/apt/*.bin
apt autoclean -y

# Remover fuentes problemáticas (especialmente CD-ROM)
echo "Removiendo fuentes de repositorios problemáticas..."
sed -i '/cdrom:/d' /etc/apt/sources.list
find /etc/apt/sources.list.d/ -type f -exec sed -i '/cdrom:/d' {} \;

#Actualización de repositorios
echo "Actualizando lista de repositorios..."
apt update

echo
echo "Actualizando programas..."
# Aumentar el espacio disponible antes de upgrade
apt upgrade -y || {
    echo "Upgrade inicial fallido, intentando limpieza adicional..."
    apt clean
    rm -rf /tmp/*
    apt upgrade -y
}

#Limpieza después del upgrade
echo
echo "Eliminando paquetes innecesarios..."
apt autoremove -y

echo
echo "Limpiando cache..."
apt autoclean

#Backup
echo
echo "Creando Backup…"

# Array de directorios a respaldar
DIRS_BACKUP=(
    "$HOME_USUARIO/Documentos"
    "$HOME_USUARIO/Desktop"
    "$HOME_USUARIO/.ssh"
    "$HOME_USUARIO/.config"
)

BACKUP_CREADO=0
for DIR in "${DIRS_BACKUP[@]}"; do
    if [ -d "$DIR" ]; then
        NOMBRE_DIR=$(basename "$DIR")
        echo "Respaldando $DIR..."
        tar -czf "$BACKUP_DIR/backup_${NOMBRE_DIR}_$FECHA.tar.gz" \
            --exclude='*/.cache' \
            --exclude='*/.*cache*' \
            "$DIR" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "Backup de $NOMBRE_DIR creado correctamente."
            BACKUP_CREADO=1
        else
            echo "Error al crear backup de $NOMBRE_DIR."
        fi
    fi
done

if [ $BACKUP_CREADO -eq 0 ]; then
    echo "Intento de backup del home completo..."
    tar -czf "$BACKUP_DIR/backup_home_$FECHA.tar.gz" \
        --exclude="$HOME_USUARIO/.cache" \
        --exclude="$HOME_USUARIO/.local/share/Trash" \
        "$HOME_USUARIO" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "Backup del home creado."
    else
        echo "Error al crear backup del home"
    fi
fi

#Información del Sistema
echo
echo "INFORMACIÓN DEL SISTEMA"

echo
echo "Uso del disco:"
df -h

echo
echo "Memoria RAM:"
free -h

echo
echo "Tiempo encendido:"
uptime

echo
echo "CPU:"
nproc
lscpu | grep "Model name"

#Tamaño de los backups
echo
echo "Backups existentes:"
du -sh "$BACKUP_DIR"
ls -lh "$BACKUP_DIR" | tail -5

#Tiempo de ejecución
FIN=$(date +%s)
TIEMPO=$((FIN-INICIO))

echo
echo "Mantenimiento finalizado correctamente."
echo "Tiempo empleado: $TIEMPO segundos."
echo "Log generado en:"
echo "$LOG"
