# Cómo se construye galera.mdl (Capa 2)

## Propósito

Este documento describe los pasos para construir la imagen de cluster Galera que hereda de rocky10x.img, implementando las decisiones declaradas en galera.mdl.yml.

## 1. Instalación

Ejecute los siguientes comandos para instalar los paquetes de Galera Cluster:

```bash
dnf install -y galera-4
dnf install -y mariadb-server-galera
```

## 2. Configuración de Galera Cluster

Cree el archivo de configuración de Galera en `/etc/my.cnf.d/galera.cnf`:

```bash
vi /etc/my.cnf.d/galera.cnf
```

Agregue la siguiente configuración con los valores específicos de su cluster:

```ini
[mariadb]
# Variables wsrep
wsrep_on = ON
wsrep_provider = /usr/lib64/galera-4/libgalera_smm.so
wsrep_cluster_address = gcomm://IP_NODO1,IP_NODO2,IP_NODO3
binlog_format = ROW

# Identificación del nodo
wsrep_node_name = NOMBRE_NODO
wsrep_node_address = IP_NODO

# Storage engine
default_storage_engine = InnoDB
innodb_autoinc_lock_mode = 2
innodb_flush_log_at_trx_commit = 0

# State Snapshot Transfer
wsrep_sst_method = mariadb-backup

# Performance
wsrep_slave_threads = 4
```

**Nota:** Reemplace los valores `NOMBRE_NODO`, `IP_NODO`, `IP_NODO1`, `IP_NODO2`, `IP_NODO3` con los valores específicos.

## 3. SELinux

Ejecute los siguientes comandos para configurar los contextos de puerto de Galera en SELinux:

```bash
semanage port -a -t mysqld_port_t -p tcp 4567
semanage port -a -t mysqld_port_t -p udp 4567
semanage port -a -t mysqld_port_t -p tcp 4568
semanage port -a -t mysqld_port_t -p tcp 4444
```

Verifique los contextos configurados:

```bash
semanage port -l | grep mysqld_port_t
```

Salida esperada debe incluir los puertos 4567, 4568 y 4444.

## 4. Firewall

Ejecute los siguientes comandos para abrir los puertos de Galera en el firewall:

```bash
firewall-cmd --permanent --add-port=4567/tcp
firewall-cmd --permanent --add-port=4567/udp
firewall-cmd --permanent --add-port=4568/tcp
firewall-cmd --permanent --add-port=4444/tcp
firewall-cmd --reload
```

Verifique las reglas configuradas:

```bash
firewall-cmd --list-ports
```

Salida esperada: `4567/tcp 4567/udp 4568/tcp 4444/tcp`
