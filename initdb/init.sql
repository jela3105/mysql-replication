CREATE DATABASE cinestelar;

USE cinestelar;

CREATE TABLE Pelicula (
    ID_Pelicula VARCHAR(50) PRIMARY KEY,
    Nombre VARCHAR(25) NOT NULL,
    Resumen VARCHAR(255),
    Año YEAR NOT NULL,
    Duración TIME NOT NULL,
    Idioma SMALLINT NOT NULL,
    Director VARCHAR(35),
    Costo DECIMAL(10,2) NOT NULL
);

CREATE TABLE Sala (
    ID_Sala INT(5) PRIMARY KEY AUTO_INCREMENT,
    Capacidad INT(3) NOT NULL,
    Numero_Sala INT(2) NOT NULL
);

CREATE TABLE Funcion (
    ID_Funcion INT(3) PRIMARY KEY AUTO_INCREMENT,
    Horario DATETIME NOT NULL,
    Pelicula_ID_Pelicula VARCHAR(50) NOT NULL,
    Sala_ID_Sala INT(5) NOT NULL,
    FOREIGN KEY (Pelicula_ID_Pelicula) REFERENCES Pelicula(ID_Pelicula) ON DELETE RESTRICT,
    FOREIGN KEY (Sala_ID_Sala) REFERENCES Sala(ID_Sala) ON DELETE RESTRICT
);

CREATE TABLE Empleados (
    ID_EMP VARCHAR(6) PRIMARY KEY,
    Apellido_P VARCHAR(15) NOT NULL,
    Apellido_M VARCHAR(15) NOT NULL,
    Correo VARCHAR(25) UNIQUE NOT NULL,
    Fecha_Nacimiento DATE NOT NULL
);

CREATE TABLE Ticket (
    ID_Ticket INT(3) PRIMARY KEY AUTO_INCREMENT,
    Funcion_ID_Funcion INT(3) NOT NULL,
    Empleados_ID_EMP VARCHAR(6) NOT NULL,
    FOREIGN KEY (Funcion_ID_Funcion) REFERENCES Funcion(ID_Funcion) ON DELETE RESTRICT,
    FOREIGN KEY (Empleados_ID_EMP) REFERENCES Empleados(ID_EMP) ON DELETE RESTRICT
);

CREATE TABLE Detalle_Ticket (
    ID_Detalle INT(3) PRIMARY KEY AUTO_INCREMENT,
    Fila CHAR(1) NOT NULL,
    Numero INT(2) NOT NULL,
    Ticket_ID_Ticket INT(3) NOT NULL,
    FOREIGN KEY (Ticket_ID_Ticket) REFERENCES Ticket(ID_Ticket) ON DELETE RESTRICT
);