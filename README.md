# MySQL Master-Slave Replication with Docker Compose

Este repositorio contiene la configuración para montar un entorno de replicación **Master-Slave** de MySQL utilizando Docker Compose.

## **Índice**
- [Español](#español)
  - [Estructura del Proyecto](#estructura-del-proyecto)
  - [Requisitos Previos](#requisitos-previos)
  - [Configurar IP Estática en Pop!_OS](#configurar-ip-estática-en-pop_os-linux)
  - [Abrir el Puerto 3306](#abrir-el-puerto-3306-en-el-firewall)
  - [Configuración de Variables de Entorno](#configuración-de-variables-de-entorno)
  - [Configurar y Levantar los Contenedores](#configurar-y-levantar-los-contenedores)
  - [Configurar la Replicación](#configurar-la-replicación-en-el-slave)
  - [Verificar la Replicación](#verificar-que-todo-funciona)
  - [Detener y Eliminar Contenedores](#detener-y-eliminar-los-contenedores)

- [English](#english)
  - [Project Structure](#project-structure)
  - [Prerequisites](#prerequisites)
  - [Set Static IP in Pop!_OS](#set-static-ip-in-pop_os-linux)
  - [Open Port 3306](#open-port-3306-in-firewall)
  - [Environment Variables](#environment-variables)
  - [Setup and Start Containers](#setup-and-start-containers)
  - [Configure Replication](#configure-replication-on-slave)
  - [Verify Replication](#verify-replication)
  - [Stop and Remove Containers](#stop-and-remove-containers)

---

## **Español**

### **Estructura del Proyecto**
```
/proyecto
  |├── source/
  |   |├── docker-compose.yml
  |   |└── .env
  |├── replica/
  |   |├── docker-compose.yml
  |   |└── .env
  |├── initdb/
  |   |└── init.sql
  |└── README.md
```

### **Requisitos Previos**

- Tener instalado **Docker** y **Docker Compose**.
- Configurar IPs estáticas en los equipos donde correrán los contenedores.
- Abrir el puerto **3306** en el Master para permitir la conexión del Slave.

## **1. Configurar IP Estática en Pop!_OS (Linux)**

1. Abre la configuración de red desde la interfaz gráfica o usa la terminal.
2. Ejecuta el siguiente comando para listar las interfaces de red:
   ```bash
   ip addr show
   ```
3. Identifica la interfaz de conexión (ejemplo: `wlp2s0` para WiFi o `eth0` para Ethernet).
4. Edita la configuración de red:
   ```bash
   sudo nano /etc/netplan/01-network-manager-all.yaml
   ```
5. Agrega o modifica la configuración de la interfaz correspondiente:
   ```yaml
   network:
     version: 2
     renderer: networkd
     ethernets:
       eth0:
         dhcp4: no
         addresses:
           - 192.168.0.100/24
         gateway4: 192.168.0.1
         nameservers:
           addresses:
             - 8.8.8.8
             - 8.8.4.4
   ```
6. Aplica los cambios y reinicia la red:
   ```bash
   sudo netplan apply
   ```

### **Abrir el Puerto 3306 en el Firewall**

1. Permitir conexiones en el puerto 3306:
   ```bash
   sudo ufw allow 3306/tcp
   ```
2. Habilitar el firewall si no está activo:
   ```bash
   sudo ufw enable
   ```
3. Verificar que la regla se aplicó:
   ```bash
   sudo ufw status
   ```

## **2. Configuración de Variables de Entorno**

Ambos servicios (Master y Slave) utilizan un archivo `.env` para definir las credenciales de MySQL y los parámetros de replicación.

### **Archivo `.env` en Master (`source/.env`)**
```ini
MYSQL_ROOT_PASSWORD=
MYSQL_REPLICATION_USER=r
MYSQL_REPLICATION_PASSWORD=r
MYSQL_MASTER_HOST=
MYSQL_MASTER_PORT=
MYSQL_MASTER_SERVER_ID=
```

### **Archivo `.env` en Slave (`replica/.env`)**
```ini
MYSQL_ROOT_PASSWORD=
MYSQL_REPLICATION_USER=
MYSQL_REPLICATION_PASSWORD=
MYSQL_SLAVE_HOST=
MYSQL_SLAVE_PORT=
MYSQL_SLAVE_SERVER_ID=
```

## **3. Configurar y Levantar los Contenedores**

### **Levantar el Master**
```bash
cd source/
docker-compose up -d
```
Verificar que el contenedor está corriendo:
```bash
docker ps
```

### **Levantar el Slave**
```bash
cd ../replica/
docker-compose up -d
```

## **4. Configurar la Replicación en el Slave**

Conectar al Slave:
```bash
docker exec -it mysql-slave mysql -uroot -p
```
Ejecutar los siguientes comandos en MySQL:
```sql
CHANGE MASTER TO
  MASTER_HOST='192.168.0.100',
  MASTER_USER='repl_user',
  MASTER_PASSWORD='repl_pass',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=1234,
  GET_MASTER_PUBLIC_KEY=1;

START SLAVE;
SHOW SLAVE STATUS \G;
```
Si `SHOW SLAVE STATUS \G;` muestra `Slave_IO_Running: Yes`, la replicación está funcionando correctamente.

## **5. Verificar que Todo Funciona**

Desde el Master, insertar un dato de prueba:
```bash
docker exec -it mysql-master mysql -uroot -p
```
```sql
USE replicadb;
INSERT INTO test (data) VALUES ('Prueba de replicación');
```

Desde el Slave, comprobar que el dato se replicó:
```bash
docker exec -it mysql-slave mysql -uroot -p
```
```sql
USE replicadb;
SELECT * FROM test;
```
Si los datos aparecen, la replicación está funcionando correctamente. 🚀

## **6. Detener y Eliminar los Contenedores**

Para detener los contenedores sin eliminar los volúmenes:
```bash
cd source/
docker-compose down
cd ../replica/
docker-compose down
```

Para eliminar también los volúmenes (y borrar la base de datos):
```bash
cd source/
docker-compose down -v
cd ../replica/
docker-compose down -v
```

## **Conclusión**

Con esta configuración, MySQL Master-Slave quedará funcionando con Docker Compose, ejecutando un script de inicialización y almacenando las credenciales en un archivo `.env` para mayor seguridad.

## **English**

### **Project Structure**
```
/project
  |├── source/
  |   |├── docker-compose.yml
  |   |└── .env
  |├── replica/
  |   |├── docker-compose.yml
  |   |└── .env
  |├── initdb/
  |   |└── init.sql
  |└── README.md
```

## **Prerequisites**
- Install **Docker** and **Docker Compose**.
- Set static IP addresses on the machines where the containers will run.
- Open port **3306** on the Master to allow the Slave to connect.

## **Set Static IP in Pop!_OS (Linux)**
1. Open network settings from the graphical interface or use the terminal.
2. Run the following command to list network interfaces:
   ```bash
   ip addr show
   ```
3. Identify the network interface (e.g., `wlp2s0` for WiFi or `eth0` for Ethernet).
4. Edit the network configuration:
   ```bash
   sudo nano /etc/netplan/01-network-manager-all.yaml
   ```
5. Add or modify the configuration for the appropriate interface:
   ```yaml
   network:
     version: 2
     renderer: networkd
     ethernets:
       eth0:
         dhcp4: no
         addresses:
           - 192.168.0.100/24
         gateway4: 192.168.0.1
         nameservers:
           addresses:
             - 8.8.8.8
             - 8.8.4.4
   ```
6. Apply the changes and restart the network:
   ```bash
   sudo netplan apply
   ```

### **Open Port 3306 in Firewall**
1. Allow connections on port 3306:
   ```bash
   sudo ufw allow 3306/tcp
   ```
2. Enable the firewall if it is not already active:
   ```bash
   sudo ufw enable
   ```
3. Verify that the rule was applied:
   ```bash
   sudo ufw status
   ```

## **2. Environment Variables**
Both services (Master and Slave) use the same file `.env` to define the credentials of MySQL and the replication parameters.

### **File`.env` in Master (`source/.env`)**
```ini
MYSQL_ROOT_PASSWORD=
MYSQL_REPLICATION_USER=r
MYSQL_REPLICATION_PASSWORD=r
MYSQL_MASTER_HOST=
MYSQL_MASTER_PORT=
MYSQL_MASTER_SERVER_ID=
```

### **File `.env` in Slave (`replica/.env`)**
```ini
MYSQL_ROOT_PASSWORD=
MYSQL_REPLICATION_USER=
MYSQL_REPLICATION_PASSWORD=
MYSQL_SLAVE_HOST=
MYSQL_SLAVE_PORT=
MYSQL_SLAVE_SERVER_ID=
```

## **3. Setup and Start Containers**
### **Setup Master**
```bash
cd source/
docker-compose up -d
```
Verify that the container is running:
```bash
docker ps
```

### **Set up the Slave**
```bash
cd ../replica/
docker-compose up -d
```

## **4. Configure Replication on Slave**
Connect the Slave:
```bash
docker exec -it mysql-slave mysql -uroot -p
```
Execute the following commands in Mysql
```sql
CHANGE MASTER TO
  MASTER_HOST='192.168.0.100',
  MASTER_USER='repl_user',
  MASTER_PASSWORD='repl_pass',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=1234,
  GET_MASTER_PUBLIC_KEY=1;

START SLAVE;
SHOW SLAVE STATUS \G;
```
If `SHOW SLAVE STATUS \G;` shows `Slave_IO_Running: Yes`, the replication is working correctly.


## **5. Verify Replication**
From the master, insert test data:
```bash
docker exec -it mysql-master mysql -uroot -p
```
```sql
USE replicadb;
INSERT INTO test (data) VALUES ('Prueba de replicación');
```

From the Slave, checkout the replication of the data:
```bash
docker exec -it mysql-slave mysql -uroot -p
```
```sql
USE replicadb;
SELECT * FROM test;
```
If the data is there, the replication is working correctly. 🚀
...

## **6. Stop and Remove Containers**
To stop the containers without removint the volumes:
```bash
cd source/
docker-compose down
cd ../replica/
docker-compose down
```

To remove the volumes (and delete the database):
```bash
cd source/
docker-compose down -v
cd ../replica/
docker-compose down -v
```