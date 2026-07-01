# Virtualización Tipo 2 — Script de Mantenimiento en Bash

> Trabajo Práctico Integrador  
> **Autor:** Gonzalez Nahir, Rossi Franco
> **Entorno:** Linux Mint XFCE (guest) · Oracle VirtualBox 7.2.10 (host Windows)  
> **Materia:** Arquitectura y Sistemas Operativos · UTN · 2026

---

## Descripción del proyecto

Este repositorio contiene el trabajo práctico integrador sobre **virtualización de tipo 2 (hosted)**, desarrollado en una máquina virtual con **Linux Mint XFCE** corriendo sobre **Oracle VirtualBox**.

El trabajo tiene dos ejes principales:

1. **Marco teórico** sobre virtualización: qué es un hipervisor, diferencias entre tipo 1 y tipo 2, características de VirtualBox, Linux Mint y Bash como lenguaje de scripting.
2. **Caso práctico**: desarrollo, prueba, depuración y ejecución de un script en Bash que automatiza las tareas habituales de mantenimiento de un sistema GNU/Linux.

## Requisitos

### Para ejecutar el script
- Sistema operativo **GNU/Linux** (probado en Linux Mint 21 XFCE)
- **Bash** 4.0 o superior (`bash --version`)
- Gestor de paquetes **APT** (Debian/Ubuntu/Linux Mint)
- Privilegios de superusuario (`sudo`)

### Para reproducir el entorno virtualizado
- **Oracle VirtualBox 7.2.10** o superior → [descargar aquí](https://www.virtualbox.org/wiki/Downloads)
- **Extension Pack** de VirtualBox (misma versión)
- ISO de **Linux Mint XFCE** → [descargar aquí](https://www.linuxmint.com/download.php)
- Recursos mínimos recomendados para la VM:
  - RAM: **4 GB**
  - Disco: **30 GB**
  - CPU: **2 núcleos**

> Con 2 GB de RAM y 20 GB de disco la actualización de paquetes falla por espacio insuficiente. Ver sección [Problemas conocidos](#-problemas-conocidos-y-soluciones).

---

## Instalación y uso

### 1. Clonar el repositorio

Desde la terminal de Linux Mint, dentro de la máquina virtual:

```bash
git clone https://github.com/rossifrancoian/TPI-AYSO-GONZALEZ-ROSSI
cd TPI-AYSO-GONZALEZ-ROSSI
```

### 2. Dar permisos de ejecución al script

```bash
chmod +x mantenimiento.sh
```

### 3. Ejecutar el script

El script requiere privilegios de administrador:

```bash
sudo ./mantenimiento.sh
```

> El script verifica automáticamente si se ejecuta con `sudo`. Si no es así, muestra un aviso y se detiene.

### 4. Revisar el log generado

Al finalizar, el script genera automáticamente un archivo de log en:

```
~/backups/mantenimiento_YYYY-MM-DD_HH-MM-SS.log
```

---

## ¿Qué hace el script?

El script ejecuta en orden los siguientes bloques:

| Bloque | Descripción |
|---|---|
| Verificación de permisos | Comprueba que se ejecute como root mediante `$EUID` |
| Limpieza previa | Libera el caché de APT antes de actualizar (`apt clean`) |
| Eliminación de repositorios problemáticos | Remueve entradas de CD-ROM en `sources.list` con `sed` |
| Actualización del sistema | `apt update` + `apt upgrade -y` con reintento automático si falla |
| Limpieza posterior | `apt autoremove -y` + `apt autoclean` |
| Backup | Crea archivos `.tar.gz` comprimidos de Documentos, Desktop, `.ssh` y `.config` |
| Info del sistema | Muestra uso de disco (`df -h`), RAM (`free -h`), CPU (`lscpu`) y uptime |
| Log | Todo lo mostrado en pantalla se guarda en `~/backups/` con `tee` |
| Tiempo de ejecución | Calcula y muestra los segundos empleados en el proceso completo |

---

## Problemas conocidos y soluciones

### Error: espacio insuficiente en `/var/cache/apt/archives/`

```
E: You don't have enough free space in /var/cache/apt/archives/
```

**Causa:** La VM tenía asignados solo 20 GB de disco, insuficientes para descargar las actualizaciones.  
**Solución:** Aumentar el disco virtual de la VM a **30 GB** desde la configuración de VirtualBox, o ejecutar manualmente `sudo apt clean` antes de correr el script.

---

### Error: la carpeta Documentos no existe

```
tar: /home/usuario/Documentos: Cannot stat: No such file or directory
```

**Causa:** Linux Mint XFCE no crea la carpeta `Documentos` automáticamente en todos los idiomas o configuraciones.  
**Solución:** El script fue modificado para detectar este caso y realizar en su lugar un backup del directorio home completo (`~/`), excluyendo caché y papelera.

---

### Errores persistentes tras correcciones al código

**Causa:** Los errores no eran de código sino de infraestructura: los recursos asignados a la VM eran insuficientes.  
**Solución:** Crear una nueva VM con **4 GB de RAM** y **30 GB de disco**. Con esa configuración el script funcionó correctamente de principio a fin.

>**Aprendizaje clave:** no todos los problemas se resuelven modificando código. Distinguir entre un error de software y una limitación de infraestructura es una habilidad fundamental en administración de sistemas.

---

## Entorno de desarrollo

| Componente | Detalle |
|---|---|
| Host OS | Windows [versión] |
| Hipervisor | Oracle VirtualBox 7.2.10 |
| Guest OS | Linux Mint 21 XFCE |
| Shell | Bash 5.x |
| RAM asignada (VM final) | 4 GB |
| Disco asignado (VM final) | 30 GB |
| CPU asignada (VM final) | 2 núcleos |
| Modo de red | NAT |

---

## Fuentes y documentación oficial

- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [Oracle VirtualBox User Manual](https://www.virtualbox.org/manual/)
- [apt-get(8) — Debian Manpages](https://manpages.debian.org/unstable/apt/apt-get.8.en.html)
- [GNU tar Manual](https://www.gnu.org/software/tar/manual/)
- [GNU sed Manual](https://www.gnu.org/software/sed/manual/sed.html)
- [Linux Mint — Sitio oficial](https://www.linuxmint.com/)
- [Xfce Desktop Environment](https://xfce.org/)
- [Sudo Manual](https://www.sudo.ws/docs/man/1.8.22/sudo.man/)
- [df(1) — Linux man page](https://man7.org/linux/man-pages/man1/df.1.html)
- [free(1) — Linux man page](https://man7.org/linux/man-pages/man1/free.1.html)
- [lscpu(1) — Linux man page](https://man7.org/linux/man-pages/man1/lscpu.1.html)

---

## Autores

- **Rossi Franco**
- **Gonzalez Nahir** 

---

*Trabajo práctico desarrollado con fines educativos.*
