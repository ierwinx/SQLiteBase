-- ============================================================
--  PELICULAS.SQL — Práctica de SQLite
--  Incluye: tablas sin relación, 1:1, 1:N y N:M
-- ============================================================

PRAGMA foreign_keys = ON;  -- Activar claves foráneas en SQLite


-- ============================================================
-- SECCIÓN 1: TABLAS SIN RELACIÓN
-- Datos de apoyo independientes
-- ============================================================

CREATE TABLE IF NOT EXISTS Generos (
    id_genero   INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre      TEXT    NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE IF NOT EXISTS Paises (
    id_pais  INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre   TEXT    NOT NULL UNIQUE,
    codigo   TEXT    NOT NULL UNIQUE  -- ej: US, MX, FR
);

INSERT INTO Generos (nombre, descripcion) VALUES
    ('Acción',     'Películas llenas de secuencias de alto impacto'),
    ('Drama',      'Historias con conflictos emocionales profundos'),
    ('Ciencia Ficción', 'Narrativas basadas en avances científicos o tecnológicos'),
    ('Comedia',    'Películas diseñadas para entretener y hacer reír'),
    ('Terror',     'Películas que generan miedo y suspenso');

INSERT INTO Paises (nombre, codigo) VALUES
    ('Estados Unidos', 'US'),
    ('México',         'MX'),
    ('Francia',        'FR'),
    ('Reino Unido',    'UK'),
    ('Japón',          'JP');


-- ============================================================
-- SECCIÓN 2: RELACIÓN 1 : 1
-- Una Película tiene exactamente un registro de DetallesTecnicos
-- ============================================================

CREATE TABLE IF NOT EXISTS Peliculas (
    id_pelicula  INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo       TEXT    NOT NULL,
    anio         INTEGER NOT NULL,
    duracion_min INTEGER NOT NULL,
    id_genero    INTEGER,                              -- referencia opcional a Generos
    id_pais      INTEGER,                              -- referencia opcional a Paises
    FOREIGN KEY (id_genero) REFERENCES Generos(id_genero),
    FOREIGN KEY (id_pais)   REFERENCES Paises(id_pais)
);

-- Tabla 1:1 con Peliculas (un único detalle técnico por película)
CREATE TABLE IF NOT EXISTS DetallesTecnicos (
    id_detalle     INTEGER PRIMARY KEY,                -- mismo PK que la película (1:1 estricto)
    resolucion     TEXT    NOT NULL,                   -- ej: 4K, 1080p
    formato_audio  TEXT    NOT NULL,                   -- ej: Dolby Atmos, DTS
    subtitulos     TEXT,
    clasificacion  TEXT    NOT NULL,                   -- ej: G, PG-13, R
    FOREIGN KEY (id_detalle) REFERENCES Peliculas(id_pelicula)
);

INSERT INTO Peliculas (titulo, anio, duracion_min, id_genero, id_pais) VALUES
    ('Inception',              2010, 148, 3, 1),
    ('El Padrino',             1972, 175, 2, 1),
    ('Parasite',               2019, 132, 2, 2),
    ('Interstellar',           2014, 169, 3, 1),
    ('Coco',                   2017, 105, 4, 2),
    ('Ringu',                  1998,  96, 5, 5),
    ('Amélie',                 2001, 122, 4, 3),
    ('Mad Max: Fury Road',     2015, 120, 1, 1);

-- Detalles técnicos (id_detalle debe coincidir con id_pelicula — relación 1:1)
INSERT INTO DetallesTecnicos (id_detalle, resolucion, formato_audio, subtitulos, clasificacion) VALUES
    (1, '4K',    'Dolby Atmos', 'Español, Francés',  'PG-13'),
    (2, '1080p', 'Dolby 5.1',   'Español',           'R'),
    (3, '4K',    'DTS-HD',      'Inglés, Español',   'R'),
    (4, '4K',    'Dolby Atmos', 'Español, Japonés',  'PG-13'),
    (5, '1080p', 'Dolby 5.1',   'Inglés',            'PG'),
    (6, '1080p', 'Estéreo',     'Inglés, Español',   'R'),
    (7, '1080p', 'DTS',         'Inglés',            'R'),
    (8, '4K',    'Dolby Atmos', 'Español',           'R');


-- ============================================================
-- SECCIÓN 3: RELACIÓN 1 : N  (uno a muchos)
-- Un Director puede dirigir muchas Películas,
-- pero cada Película tiene solo un Director
-- ============================================================

CREATE TABLE IF NOT EXISTS Directores (
    id_director  INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre       TEXT    NOT NULL,
    apellido     TEXT    NOT NULL,
    nacionalidad TEXT
);

-- Se agrega la FK en Peliculas apuntando al Director
ALTER TABLE Peliculas ADD COLUMN id_director INTEGER
    REFERENCES Directores(id_director);

INSERT INTO Directores (nombre, apellido, nacionalidad) VALUES
    ('Christopher', 'Nolan',       'Británico'),
    ('Francis',     'Ford Coppola','Estadounidense'),
    ('Bong',        'Joon-ho',     'Surcoreano'),
    ('Lee',         'Unkrich',     'Estadounidense'),
    ('Hideo',       'Nakata',      'Japonés'),
    ('Jean-Pierre', 'Jeunet',      'Francés'),
    ('George',      'Miller',      'Australiano');

-- Asignar directores a las películas (relación 1:N)
UPDATE Peliculas SET id_director = 1 WHERE id_pelicula IN (1, 4);  -- Nolan
UPDATE Peliculas SET id_director = 2 WHERE id_pelicula = 2;         -- Coppola
UPDATE Peliculas SET id_director = 3 WHERE id_pelicula = 3;         -- Bong Joon-ho
UPDATE Peliculas SET id_director = 4 WHERE id_pelicula = 5;         -- Unkrich
UPDATE Peliculas SET id_director = 5 WHERE id_pelicula = 6;         -- Nakata
UPDATE Peliculas SET id_director = 6 WHERE id_pelicula = 7;         -- Jeunet
UPDATE Peliculas SET id_director = 7 WHERE id_pelicula = 8;         -- Miller


-- ============================================================
-- SECCIÓN 4: RELACIÓN N : M  (muchos a muchos)
-- Una Película tiene muchos Actores,
-- y un Actor puede aparecer en muchas Películas
-- (tabla intermedia: Reparto)
-- ============================================================

CREATE TABLE IF NOT EXISTS Actores (
    id_actor  INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre    TEXT    NOT NULL,
    apellido  TEXT    NOT NULL,
    fecha_nac TEXT                  -- formato YYYY-MM-DD
);

-- Tabla puente (N:M) con atributo propio: el personaje que interpreta
CREATE TABLE IF NOT EXISTS Reparto (
    id_pelicula  INTEGER NOT NULL,
    id_actor     INTEGER NOT NULL,
    personaje    TEXT    NOT NULL,
    rol          TEXT    DEFAULT 'Secundario',  -- 'Principal' o 'Secundario'
    PRIMARY KEY (id_pelicula, id_actor),
    FOREIGN KEY (id_pelicula) REFERENCES Peliculas(id_pelicula),
    FOREIGN KEY (id_actor)    REFERENCES Actores(id_actor)
);

INSERT INTO Actores (nombre, apellido, fecha_nac) VALUES
    ('Leonardo', 'DiCaprio',  '1974-11-11'),
    ('Joseph',   'Gordon-Levitt', '1981-02-17'),
    ('Marlon',   'Brando',    '1924-04-03'),
    ('Al',       'Pacino',    '1940-04-25'),
    ('Song',     'Kang-ho',   '1967-01-17'),
    ('Matthew',  'McConaughey','1969-11-04'),
    ('Anne',     'Hathaway',  '1982-11-12'),
    ('Tom',      'Hardy',     '1977-09-15'),
    ('Audrey',   'Tautou',    '1976-08-09'),
    ('Charlize', 'Theron',    '1975-08-07');

-- Reparto de Inception (id=1)
INSERT INTO Reparto (id_pelicula, id_actor, personaje, rol) VALUES
    (1, 1, 'Dom Cobb',         'Principal'),
    (1, 2, 'Arthur',           'Principal'),
    (1, 8, 'Eames',            'Secundario');

-- Reparto de El Padrino (id=2)
INSERT INTO Reparto (id_pelicula, id_actor, personaje, rol) VALUES
    (2, 3, 'Vito Corleone',    'Principal'),
    (2, 4, 'Michael Corleone', 'Principal');

-- Reparto de Parasite (id=3)
INSERT INTO Reparto (id_pelicula, id_actor, personaje, rol) VALUES
    (3, 5, 'Ki-taek',          'Principal');

-- Reparto de Interstellar (id=4)
INSERT INTO Reparto (id_pelicula, id_actor, personaje, rol) VALUES
    (4, 6, 'Cooper',           'Principal'),
    (4, 7, 'Brand',            'Principal');

-- Reparto de Mad Max (id=8)
INSERT INTO Reparto (id_pelicula, id_actor, personaje, rol) VALUES
    (8, 10, 'Furiosa',         'Principal'),
    (8,  8, 'Max Rockatansky', 'Principal');

-- Reparto de Amélie (id=7)
INSERT INTO Reparto (id_pelicula, id_actor, personaje, rol) VALUES
    (7, 9, 'Amélie Poulain',   'Principal');


-- ============================================================
-- SECCIÓN 5: CONSULTAS DE EJEMPLO
-- ============================================================

-- 1. Ver todas las películas con su género y país
SELECT p.titulo, p.anio, g.nombre AS genero, pa.nombre AS pais
FROM Peliculas p
LEFT JOIN Generos g  ON p.id_genero = g.id_genero
LEFT JOIN Paises pa  ON p.id_pais   = pa.id_pais
ORDER BY p.anio DESC;

-- 2. Relación 1:1 — Película con sus detalles técnicos
SELECT p.titulo, d.resolucion, d.formato_audio, d.clasificacion
FROM Peliculas p
INNER JOIN DetallesTecnicos d ON p.id_pelicula = d.id_detalle;

-- 3. Relación 1:N — Películas dirigidas por cada director
SELECT dir.nombre || ' ' || dir.apellido AS director,
       COUNT(p.id_pelicula)              AS total_peliculas
FROM Directores dir
LEFT JOIN Peliculas p ON p.id_director = dir.id_director
GROUP BY dir.id_director
ORDER BY total_peliculas DESC;

-- 4. Relación N:M — Actores que aparecen en cada película
SELECT p.titulo, a.nombre || ' ' || a.apellido AS actor,
       r.personaje, r.rol
FROM Reparto r
INNER JOIN Peliculas p ON r.id_pelicula = p.id_pelicula
INNER JOIN Actores   a ON r.id_actor    = a.id_actor
ORDER BY p.titulo, r.rol;

-- 5. Relación N:M inversa — En cuántas películas aparece cada actor
SELECT a.nombre || ' ' || a.apellido AS actor,
       COUNT(r.id_pelicula)          AS peliculas
FROM Actores a
LEFT JOIN Reparto r ON a.id_actor = r.id_actor
GROUP BY a.id_actor
ORDER BY peliculas DESC;

-- 6. Consulta completa — película, director, actores principales y detalles técnicos
SELECT
    p.titulo,
    p.anio,
    dir.nombre || ' ' || dir.apellido   AS director,
    a.nombre  || ' ' || a.apellido      AS actor_principal,
    r.personaje,
    dt.resolucion,
    dt.clasificacion
FROM Peliculas p
LEFT JOIN Directores      dir ON p.id_director  = dir.id_director
LEFT JOIN DetallesTecnicos dt ON p.id_pelicula  = dt.id_detalle
LEFT JOIN Reparto           r ON p.id_pelicula  = r.id_pelicula AND r.rol = 'Principal'
LEFT JOIN Actores           a ON r.id_actor     = a.id_actor
ORDER BY p.titulo, a.apellido;
