-- Script SQL Server para la creación de base de datos de Planes de Trabajo Docente
-- Basado en el archivo Excel "Plan de Trabajo Docente 2025.xlsx"

-- Creación de la base de datos
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

-- Tabla de Áreas Académicas
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

-- Tabla de Semestres Académicos
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
    NombreEje NVARCHAR(100) NOT NULL -- (Docencia, Investigación, Extensión, etc.)
);

-- Tabla de Tipos de Actividades
CREATE TABLE TipoActividad (
    IdTipoActividad INT IDENTITY(1,1) PRIMARY KEY,
    NombreTipo NVARCHAR(150) NOT NULL,
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional)
);

-- Tabla para listas de actividades sugeridas de investigación
CREATE TABLE ActividadInvestigacion (
    IdActividadInvestigacion INT IDENTITY(1,1) PRIMARY KEY,
    NombreActividad NVARCHAR(255) NOT NULL,
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional)
);

-- Tabla para listas de actividades sugeridas de extensión
CREATE TABLE ActividadExtension (
    IdActividadExtension INT IDENTITY(1,1) PRIMARY KEY,
    NombreActividad NVARCHAR(255) NOT NULL,
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional)
);

-- Tabla para listas de actividades sugeridas de oferta académica y autoevaluación
CREATE TABLE ActividadAcademica (
    IdActividadAcademica INT IDENTITY(1,1) PRIMARY KEY,
    NombreActividad NVARCHAR(255) NOT NULL,
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional)
);

-- Tabla de relación entre TipoActividad y las actividades sugeridas
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

-- Tabla de Porcentajes por Ítem PT
CREATE TABLE PorcentajeItemPT (
    IdPorcentaje INT IDENTITY(1,1) PRIMARY KEY,
    IdPlanTrabajo INT FOREIGN KEY REFERENCES PlanTrabajo(IdPlanTrabajo),
    IdEjeMisional INT FOREIGN KEY REFERENCES EjeMisional(IdEjeMisional),
    Horas INT NOT NULL,
    Porcentaje DECIMAL(5,2) NOT NULL
);

-- Inserción de datos iniciales básicos
-- Insertar datos de Escalafón Docente
INSERT INTO EscalafonDocente (NombreEscalafon) VALUES 
('Ocasional'), ('Asistente'), ('Asociado'), ('Titular');

-- Insertar datos de Estados de Actividad
INSERT INTO EstadoActividad (NombreEstado) VALUES 
('No iniciada'), ('En curso'), ('Aplazada'), ('Completada'), ('No realizada');

-- Insertar datos de Ejes Misionales
INSERT INTO EjeMisional (NombreEje) VALUES 
('Docencia'), ('Investigación'), ('Extensión'), ('Gestión Administrativa');

-- Insertar algunas actividades de investigación
INSERT INTO ActividadInvestigacion (NombreActividad, IdEjeMisional) VALUES
('Desarrollo de proyecto de Investigación interno', 2),
('Desarrollo de proyecto de investigación externo', 2),
('Evaluador interno o externo de proyectos de investigación', 2),
('Tutor jóvenes investigadores', 2),
('Dirección grupo de investigación', 2),
('Coordinación semillero de investigación', 2),
('Apoyo semillero de investigación', 2),
('Enlace de investigación Facultad o programa', 2),
('Participación en redes nacionales o internacionales', 2);

-- Insertar algunas actividades de extensión
INSERT INTO ActividadExtension (NombreActividad, IdEjeMisional) VALUES
('Programas y proyectos especiales', 3),
('Diseño programa de formación de extensión (diplomado o curso)', 3),
('Tutoría programa de extensión', 3),
('Revisión y actualización de programa de formación', 3),
('Formulación de proyecto para acceder a recursos de cooperación nacional o internacional', 3),
('Coordinación proyecto de cooperación/extensión', 3),
('Asesoría, acompañamiento, capacitación y orientación en proyecto de cooperación', 3),
('Asesoría, acompañamiento, capacitación y orientación a empresas', 3),
('Establecimiento de convenio', 3);

-- Insertar algunas actividades académicas
INSERT INTO ActividadAcademica (NombreActividad, IdEjeMisional) VALUES
('Construcción de cursos', 1),
('Actualización de cursos (Contenido, evaluación)', 1),
('Diagnóstico de cursos', 1),
('Validación de cursos', 1),
('Autoevaluación de programa académico', 1),
('Seguimiento planes de mejoramiento', 1),
('Mantenimiento de documentos maestros', 1),
('Informes de condiciones', 1),
('Reformas curriculares renovacion de registro/actiualización de condiciones calidad', 1);

-- Insertar algunos tipos de actividades para poder relacionarlos
INSERT INTO TipoActividad (NombreTipo, IdEjeMisional) VALUES
('Asignatura Pregrado', 1),
('Asesoría de Trabajos de Grado', 1),
('Proyectos de Investigación', 2),
('Dirección de Semilleros', 2),
('Proyectos de Extensión', 3),
('Capacitación Externa', 3),
('Gestión de Programas', 4),
('Comités Institucionales', 4);

SELECT * FROM TipoActividad

-- Insertar relaciones para TipoActividad_ActividadInvestigacion
INSERT INTO TipoActividad_ActividadInvestigacion (IdTipoActividad, IdActividadInvestigacion) VALUES
(3, 1), -- Proyectos de Investigación - Desarrollo de proyecto de Investigación interno
(3, 2), -- Proyectos de Investigación - Desarrollo de proyecto de investigación externo
(4, 6), -- Dirección de Semilleros - Coordinación semillero de investigación
(4, 7); -- Dirección de Semilleros - Apoyo semillero de investigación

SELECT * FROM TipoActividad_ActividadInvestigacion

-- Insertar relaciones para TipoActividad_ActividadExtension
INSERT INTO TipoActividad_ActividadExtension (IdTipoActividad, IdActividadExtension) VALUES
(5, 1), -- Proyectos de Extensión - Programas y proyectos especiales
(5, 5), -- Proyectos de Extensión - Formulación de proyecto para acceder a recursos de cooperación
(6, 2), -- Capacitación Externa - Diseño programa de formación de extensión
(6, 3); -- Capacitación Externa - Tutoría programa de extensión

-- Insertar relaciones para TipoActividad_ActividadAcademica
INSERT INTO TipoActividad_ActividadAcademica (IdTipoActividad, IdActividadAcademica) VALUES
(1, 1), -- Asignatura Pregrado - Construcción de cursos
(1, 2), -- Asignatura Pregrado - Actualización de cursos
(2, 5), -- Asesoría de Trabajos de Grado - Autoevaluación de programa académico
(7, 8); -- Gestión de Programas - Informes de condiciones

SELECT * FROM TipoActividad_ActividadAcademica