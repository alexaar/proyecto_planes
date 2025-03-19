-- Script SQL Server para la creaci�n de base de datos de Planes de Trabajo Docente
-- Basado en el archivo Excel "Plan de Trabajo Docente 2025.xlsx"

-- Creaci�n de la base de datos
CREATE DATABASE PlanTrabajoDocente;
GO

USE PlanTrabajoDocente;
GO

-- Tabla de Facultades
CREATE TABLE Facultad (
    IdFacultad INT IDENTITY(1,1) PRIMARY KEY,
    NombreFacultad NVARCHAR(100) NOT NULL,
    CentroCosto NVARCHAR(20) NULL
);

-- Tabla de �reas Acad�micas
CREATE TABLE Area (
    IdArea INT IDENTITY(1,1) PRIMARY KEY,
    NombreArea NVARCHAR(100) NOT NULL,
    IdFacultad INT FOREIGN KEY REFERENCES Facultad(IdFacultad)
);

-- Tabla de Escalafones Docentes
CREATE TABLE EscalafonDocente (
    IdEscalafon INT IDENTITY(1,1) PRIMARY KEY,
    NombreEscalafon NVARCHAR(50) NOT NULL -- (Ocasional, Asistente, Asociado, Titular)
);

-- Tabla de Docentes
CREATE TABLE Docente (
    IdDocente INT IDENTITY(1,1) PRIMARY KEY,
    Nombres NVARCHAR(50) NOT NULL,
    Apellidos NVARCHAR(50) NOT NULL,
    IdEscalafon INT FOREIGN KEY REFERENCES EscalafonDocente(IdEscalafon),
    IdArea INT FOREIGN KEY REFERENCES Area(IdArea)
);

-- Tabla de Semestres Acad�micos
CREATE TABLE Semestre (
    IdSemestre INT IDENTITY(1,1) PRIMARY KEY,
    NumeroSemestre INT NOT NULL, -- (1 o 2)
    Anio INT NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    NumeroSemanas DECIMAL(5,2) NOT NULL,
    HorasSemestre INT NOT NULL
);

-- Tabla de Ejes Misionales
CREATE TABLE EjeMisional (
    IdEjeMisional INT IDENTITY(1,1) PRIMARY KEY,
    NombreEje NVARCHAR(100) NOT NULL -- (Docencia, Investigaci�n, Extensi�n, etc.)
);

-- Tabla de Tipos de Actividades
CREATE TABLE TipoActividad (
    IdTipoActividad INT IDENTITY(1,1) PRIMARY KEY,
    NombreTipo NVARCHAR(150) NOT NULL,
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional)
);

-- Tabla para listas de actividades sugeridas de investigaci�n
CREATE TABLE ActividadInvestigacion (
    IdActividadInvestigacion INT IDENTITY(1,1) PRIMARY KEY,
    NombreActividad NVARCHAR(255) NOT NULL,
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional)
);

-- Tabla para listas de actividades sugeridas de extensi�n
CREATE TABLE ActividadExtension (
    IdActividadExtension INT IDENTITY(1,1) PRIMARY KEY,
    NombreActividad NVARCHAR(255) NOT NULL,
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional)
);

-- Tabla para listas de actividades sugeridas de oferta acad�mica y autoevaluaci�n
CREATE TABLE ActividadAcademica (
    IdActividadAcademica INT IDENTITY(1,1) PRIMARY KEY,
    NombreActividad NVARCHAR(255) NOT NULL,
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional)
);

-- Tabla de relaci�n entre TipoActividad y las actividades sugeridas
CREATE TABLE TipoActividad_ActividadInvestigacion (
    IdTipoActividad INT FOREIGN KEY REFERENCES TipoActividad(IdTipoActividad),
    IdActividadInvestigacion INT FOREIGN KEY REFERENCES ActividadInvestigacion(IdActividadInvestigacion),
    PRIMARY KEY (IdTipoActividad, IdActividadInvestigacion)
);

CREATE TABLE TipoActividad_ActividadExtension (
    IdTipoActividad INT FOREIGN KEY REFERENCES TipoActividad(IdTipoActividad),
    IdActividadExtension INT FOREIGN KEY REFERENCES ActividadExtension(IdActividadExtension),
    PRIMARY KEY (IdTipoActividad, IdActividadExtension)
);

CREATE TABLE TipoActividad_ActividadAcademica (
    IdTipoActividad INT FOREIGN KEY REFERENCES TipoActividad(IdTipoActividad),
    IdActividadAcademica INT FOREIGN KEY REFERENCES ActividadAcademica(IdActividadAcademica),
    PRIMARY KEY (IdTipoActividad, IdActividadAcademica)
);

-- Tabla de Estados de Actividades
CREATE TABLE EstadoActividad (
    IdEstado INT IDENTITY(1,1) PRIMARY KEY,
    NombreEstado NVARCHAR(50) NOT NULL -- (No iniciada, En curso, Aplazada, Completada, No realizada)
);

-- Tabla Principal de Planes de Trabajo
CREATE TABLE PlanTrabajo (
    IdPlanTrabajo INT IDENTITY(1,1) PRIMARY KEY,
    IdDocente INT FOREIGN KEY REFERENCES Docente(IdDocente),
    IdSemestre INT FOREIGN KEY REFERENCES Semestre(IdSemestre),
    ResolucionAcademica NVARCHAR(50) NULL,
    FechaCreacion DATE NOT NULL,
    TotalHorasPlan INT NOT NULL,
    Observaciones NVARCHAR(500) NULL
);

-- Tabla de Actividades del Plan de Trabajo
CREATE TABLE ActividadPlanTrabajo (
    IdActividadPlan INT IDENTITY(1,1) PRIMARY KEY,
    IdPlanTrabajo INT FOREIGN KEY REFERENCES PlanTrabajo(IdPlanTrabajo),
    IdTipoActividad INT FOREIGN KEY REFERENCES TipoActividad(IdTipoActividad),
    Descripcion NVARCHAR(500) NOT NULL,
    HorasTotales INT NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    DocenteResponsable INT FOREIGN KEY REFERENCES Docente(IdDocente),
    ApoyoCoordinacion BIT DEFAULT 0,
    IdEstado INT FOREIGN KEY REFERENCES EstadoActividad(IdEstado) DEFAULT 1, -- Por defecto "No iniciada"
    ObservacionesActividad NVARCHAR(500) NULL
);

-- Tabla de Seguimiento de Actividades
CREATE TABLE SeguimientoActividad (
    IdSeguimiento INT IDENTITY(1,1) PRIMARY KEY,
    IdActividadPlan INT FOREIGN KEY REFERENCES ActividadPlanTrabajo(IdActividadPlan),
    NumeroSeguimiento INT NOT NULL, -- (1, 2, Cierre)
    FechaSeguimiento DATE NOT NULL,
    HorasEjecutadas INT NOT NULL,
    PorcentajeAvance DECIMAL(5,2) NOT NULL,
    Soportes NVARCHAR(255) NULL, -- Ruta o referencia al documento soporte
    Retroalimentacion NVARCHAR(500) NULL
);

-- Tabla de Porcentajes por �tem PT
CREATE TABLE PorcentajeItemPT (
    IdPorcentaje INT IDENTITY(1,1) PRIMARY KEY,
    IdPlanTrabajo INT FOREIGN KEY REFERENCES PlanTrabajo(IdPlanTrabajo),
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional),
    Horas INT NOT NULL,
    Porcentaje DECIMAL(5,2) NOT NULL
);

-- Inserci�n de datos iniciales b�sicos
-- Insertar datos de Escalaf�n Docente
INSERT INTO EscalafonDocente (NombreEscalafon) VALUES 
('Ocasional'), ('Asistente'), ('Asociado'), ('Titular');

-- Insertar datos de Estados de Actividad
INSERT INTO EstadoActividad (NombreEstado) VALUES 
('No iniciada'), ('En curso'), ('Aplazada'), ('Completada'), ('No realizada');

-- Insertar datos de Ejes Misionales
INSERT INTO EjeMisional (NombreEje) VALUES 
('Docencia'), ('Investigaci�n'), ('Extensi�n'), ('Gesti�n Administrativa');

-- Insertar algunas actividades de investigaci�n
INSERT INTO ActividadInvestigacion (NombreActividad, IdEjeMisional) VALUES
('Desarrollo de proyecto de Investigaci�n interno', 2),
('Desarrollo de proyecto de investigaci�n externo', 2),
('Evaluador interno o externo de proyectos de investigaci�n', 2),
('Tutor j�venes investigadores', 2),
('Direcci�n grupo de investigaci�n', 2),
('Coordinaci�n semillero de investigaci�n', 2),
('Apoyo semillero de investigaci�n', 2),
('Enlace de investigaci�n Facultad o programa', 2),
('Participaci�n en redes nacionales o internacionales', 2);

-- Insertar algunas actividades de extensi�n
INSERT INTO ActividadExtension (NombreActividad, IdEjeMisional) VALUES
('Programas y proyectos especiales', 3),
('Dise�o programa de formaci�n de extensi�n (diplomado o curso)', 3),
('Tutor�a programa de extensi�n', 3),
('Revisi�n y actualizaci�n de programa de formaci�n', 3),
('Formulaci�n de proyecto para acceder a recursos de cooperaci�n nacional o internacional', 3),
('Coordinaci�n proyecto de cooperaci�n/extensi�n', 3),
('Asesor�a, acompa�amiento, capacitaci�n y orientaci�n en proyecto de cooperaci�n', 3),
('Asesor�a, acompa�amiento, capacitaci�n y orientaci�n a empresas', 3),
('Establecimiento de convenio', 3);

-- Insertar algunas actividades acad�micas
INSERT INTO ActividadAcademica (NombreActividad, IdEjeMisional) VALUES
('Construcci�n de cursos', 1),
('Actualizaci�n de cursos (Contenido, evaluaci�n)', 1),
('Diagn�stico de cursos', 1),
('Validaci�n de cursos', 1),
('Autoevaluaci�n de programa acad�mico', 1),
('Seguimiento planes de mejoramiento', 1),
('Mantenimiento de documentos maestros', 1),
('Informes de condiciones', 1),
('Reformas curriculares renovacion de registro/actiualizaci�n de condiciones calidad', 1);

-- Insertar algunos tipos de actividades para poder relacionarlos
INSERT INTO TipoActividad (NombreTipo, IdEjeMisional) VALUES
('Asignatura Pregrado', 1),
('Asesor�a de Trabajos de Grado', 1),
('Proyectos de Investigaci�n', 2),
('Direcci�n de Semilleros', 2),
('Proyectos de Extensi�n', 3),
('Capacitaci�n Externa', 3),
('Gesti�n de Programas', 4),
('Comit�s Institucionales', 4);

SELECT * FROM TipoActividad

-- Insertar relaciones para TipoActividad_ActividadInvestigacion
INSERT INTO TipoActividad_ActividadInvestigacion (IdTipoActividad, IdActividadInvestigacion) VALUES
(3, 1), -- Proyectos de Investigaci�n - Desarrollo de proyecto de Investigaci�n interno
(3, 2), -- Proyectos de Investigaci�n - Desarrollo de proyecto de investigaci�n externo
(4, 6), -- Direcci�n de Semilleros - Coordinaci�n semillero de investigaci�n
(4, 7); -- Direcci�n de Semilleros - Apoyo semillero de investigaci�n

SELECT * FROM TipoActividad_ActividadInvestigacion

-- Insertar relaciones para TipoActividad_ActividadExtension
INSERT INTO TipoActividad_ActividadExtension (IdTipoActividad, IdActividadExtension) VALUES
(5, 1), -- Proyectos de Extensi�n - Programas y proyectos especiales
(5, 5), -- Proyectos de Extensi�n - Formulaci�n de proyecto para acceder a recursos de cooperaci�n
(6, 2), -- Capacitaci�n Externa - Dise�o programa de formaci�n de extensi�n
(6, 3); -- Capacitaci�n Externa - Tutor�a programa de extensi�n

-- Insertar relaciones para TipoActividad_ActividadAcademica
INSERT INTO TipoActividad_ActividadAcademica (IdTipoActividad, IdActividadAcademica) VALUES
(1, 1), -- Asignatura Pregrado - Construcci�n de cursos
(1, 2), -- Asignatura Pregrado - Actualizaci�n de cursos
(2, 5), -- Asesor�a de Trabajos de Grado - Autoevaluaci�n de programa acad�mico
(7, 8); -- Gesti�n de Programas - Informes de condiciones

SELECT * FROM TipoActividad_ActividadAcademica