import UIKit

class ViewController: UIViewController {

    // MARK: - Repositorios

    private let generoRepo   = GeneroRepository()
    private let paisRepo     = PaisRepository()
    private let directorRepo = DirectorRepository()
    private let actorRepo    = ActorRepository()
    private let peliculaRepo = PeliculaRepository()
    private let detalleRepo  = DetalleTecnicoRepository()
    private let repartoRepo  = RepartoRepository()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //borrarTodaLaBD()
        sembrarDatosIniciales()
        consultarTodo()
        actualiza()
    }

    // MARK: - Seed (se ejecuta una sola vez)

    /// Inserta datos de ejemplo solo si la BD está vacía.
    private func sembrarDatosIniciales() {
        guard generoRepo.getAll().isEmpty else {
            print("[Seed] La BD ya tiene datos, se omite el seed.")
            return
        }

        print("[Seed] Insertando datos iniciales...")

        // ── 1. GÉNEROS ──────────────────────────────────────────────────
        _   = Int(generoRepo.save(Genero(nombre: "Acción", descripcion: "Películas con mucha adrenalina")))
        let idDrama    = Int(generoRepo.save(Genero(nombre: "Drama",          descripcion: "Historias emotivas y reflexivas")))
        let idSciFi    = Int(generoRepo.save(Genero(nombre: "Ciencia Ficción",descripcion: "Futuros posibles e imposibles")))
        let idThriller = Int(generoRepo.save(Genero(nombre: "Thriller",       descripcion: "Suspenso y tensión constante")))

        // ── 2. PAÍSES ────────────────────────────────────────────────────
        let idUSA = Int(paisRepo.save(Pais(nombre: "Estados Unidos", codigo: "US")))
        let idUK  = Int(paisRepo.save(Pais(nombre: "Reino Unido",    codigo: "GB")))
        _ = Int(paisRepo.save(Pais(nombre: "Francia",        codigo: "FR")))

        // ── 3. DIRECTORES ────────────────────────────────────────────────
        let idNolan   = Int(directorRepo.save(Director(nombre: "Christopher", apellido: "Nolan",   nacionalidad: "Británico")))
        let idCameron = Int(directorRepo.save(Director(nombre: "James",       apellido: "Cameron",  nacionalidad: "Canadiense")))
        let idFincher = Int(directorRepo.save(Director(nombre: "David",       apellido: "Fincher",  nacionalidad: "Estadounidense")))
        let idVilleneuve = Int(directorRepo.save(Director(nombre: "Denis",    apellido: "Villeneuve", nacionalidad: "Canadiense")))

        // ── 4. ACTORES ───────────────────────────────────────────────────
        let idDiCaprio  = Int(actorRepo.save(Artista(nombre: "Leonardo", apellido: "DiCaprio",  fechaNac: "1974-11-11")))
        let idHardy     = Int(actorRepo.save(Artista(nombre: "Tom",      apellido: "Hardy",     fechaNac: "1977-09-15")))
        let idKate      = Int(actorRepo.save(Artista(nombre: "Kate",     apellido: "Winslet",   fechaNac: "1975-10-05")))
        let idZendaya   = Int(actorRepo.save(Artista(nombre: "Zendaya",  apellido: "Coleman",   fechaNac: "1996-09-01")))
        let idChalamet  = Int(actorRepo.save(Artista(nombre: "Timothée", apellido: "Chalamet",  fechaNac: "1995-12-27")))
        let idPitt      = Int(actorRepo.save(Artista(nombre: "Brad",     apellido: "Pitt",      fechaNac: "1963-12-18")))
        let idFreeman   = Int(actorRepo.save(Artista(nombre: "Morgan",   apellido: "Freeman",   fechaNac: "1937-06-01")))
        let idCillian   = Int(actorRepo.save(Artista(nombre: "Cillian",  apellido: "Murphy",    fechaNac: "1976-05-25")))

        // ── 5. PELÍCULAS ─────────────────────────────────────────────────
        // Inception (2010)
        let idInception = Int(peliculaRepo.save(Pelicula(
            titulo: "Inception",
            anio: 2010, duracionMin: 148,
            idGenero: idSciFi, idPais: idUSA, idDirector: idNolan
        )))

        // Titanic (1997)
        let idTitanic = Int(peliculaRepo.save(Pelicula(
            titulo: "Titanic",
            anio: 1997, duracionMin: 195,
            idGenero: idDrama, idPais: idUSA, idDirector: idCameron
        )))

        // Se7en (1995)
        let idSe7en = Int(peliculaRepo.save(Pelicula(
            titulo: "Se7en",
            anio: 1995, duracionMin: 127,
            idGenero: idThriller, idPais: idUSA, idDirector: idFincher
        )))

        // Dune: Part One (2021)
        let idDune = Int(peliculaRepo.save(Pelicula(
            titulo: "Dune: Part One",
            anio: 2021, duracionMin: 155,
            idGenero: idSciFi, idPais: idUSA, idDirector: idVilleneuve
        )))

        // Oppenheimer (2023)
        let idOppenheimer = Int(peliculaRepo.save(Pelicula(
            titulo: "Oppenheimer",
            anio: 2023, duracionMin: 180,
            idGenero: idDrama, idPais: idUK, idDirector: idNolan
        )))

        // ── 6. DETALLES TÉCNICOS (1:1 con Pelicula) ──────────────────────
        detalleRepo.save(DetalleTecnico(
            idDetalle: idInception,
            resolucion: "4K", formatoAudio: "Dolby Atmos",
            subtitulos: "Español, Francés", clasificacion: "PG-13"
        ))
        detalleRepo.save(DetalleTecnico(
            idDetalle: idTitanic,
            resolucion: "1080p", formatoAudio: "DTS-HD",
            subtitulos: "Español", clasificacion: "PG-13"
        ))
        detalleRepo.save(DetalleTecnico(
            idDetalle: idSe7en,
            resolucion: "1080p", formatoAudio: "Dolby Digital",
            subtitulos: nil, clasificacion: "R"
        ))
        detalleRepo.save(DetalleTecnico(
            idDetalle: idDune,
            resolucion: "4K", formatoAudio: "Dolby Atmos",
            subtitulos: "Español, Francés, Alemán", clasificacion: "PG-13"
        ))
        detalleRepo.save(DetalleTecnico(
            idDetalle: idOppenheimer,
            resolucion: "IMAX 4K", formatoAudio: "Dolby Atmos",
            subtitulos: "Español", clasificacion: "R"
        ))

        // ── 7. REPARTO (N:M Pelicula ↔ Actor) ────────────────────────────
        // Inception
        repartoRepo.save(Reparto(idPelicula: idInception, idActor: idDiCaprio, personaje: "Dom Cobb",        rol: "Principal"))
        repartoRepo.save(Reparto(idPelicula: idInception, idActor: idHardy,    personaje: "Eames",           rol: "Secundario"))

        // Titanic
        repartoRepo.save(Reparto(idPelicula: idTitanic,   idActor: idDiCaprio, personaje: "Jack Dawson",     rol: "Principal"))
        repartoRepo.save(Reparto(idPelicula: idTitanic,   idActor: idKate,     personaje: "Rose DeWitt",     rol: "Principal"))

        // Se7en
        repartoRepo.save(Reparto(idPelicula: idSe7en,     idActor: idPitt,     personaje: "Det. Mills",      rol: "Principal"))
        repartoRepo.save(Reparto(idPelicula: idSe7en,     idActor: idFreeman,  personaje: "Det. Somerset",   rol: "Principal"))

        // Dune
        repartoRepo.save(Reparto(idPelicula: idDune,      idActor: idChalamet, personaje: "Paul Atreides",   rol: "Principal"))
        repartoRepo.save(Reparto(idPelicula: idDune,      idActor: idZendaya,  personaje: "Chani",           rol: "Principal"))

        // Oppenheimer
        repartoRepo.save(Reparto(idPelicula: idOppenheimer, idActor: idCillian, personaje: "J. Robert Oppenheimer", rol: "Principal"))
        repartoRepo.save(Reparto(idPelicula: idOppenheimer, idActor: idHardy,   personaje: "Gen. Leslie Groves",    rol: "Secundario"))

        print("[Seed] ¡Datos insertados correctamente!")
    }

    // MARK: - Borrar toda la BD

    /// Elimina todos los registros de todas las tablas en orden inverso a las FK.
    private func borrarTodaLaBD() {
        let db = DatabaseManager.shared

        // Primero las tablas hijas (dependen de otras)
        db.execute("DELETE FROM Reparto;")
        db.execute("DELETE FROM DetallesTecnicos;")
        db.execute("DELETE FROM Peliculas;")
        db.execute("DELETE FROM Actores;")
        db.execute("DELETE FROM Directores;")
        db.execute("DELETE FROM Paises;")
        db.execute("DELETE FROM Generos;")

        // Reinicia los autoincrement de cada tabla
        db.execute("DELETE FROM sqlite_sequence;")

        print("[BD] Todos los datos han sido eliminados.")
    }

    // MARK: - Consultas

    /// Lee todas las tablas e imprime cada registro en formato JSON.
    private func consultarTodo() {
        print("\n[Generos]")
        generoRepo.getAll().forEach { print($0.toString()) }

        print("\n[Paises]")
        paisRepo.getAll().forEach { print($0.toString()) }

        print("\n[Directores]")
        directorRepo.getAll().forEach { print($0.toString()) }

        print("\n[Actores]")
        actorRepo.getAll().forEach { print($0.toString()) }

        print("\n[Peliculas]")
        peliculaRepo.getAll().forEach { print($0.toString()) }

        print("\n[DetallesTecnicos]")
        detalleRepo.getAll().forEach { print($0.toString()) }

        print("\n[Reparto]")
        repartoRepo.getAll().forEach { print($0.toString()) }
    }
    
    private func actualiza() {
        print("\n[se actualiza una pelicula]")
        guard var peli = peliculaRepo.get(id: 1) else { return }
        peli.titulo = "Pelicula de un sandwich dentro de otro"
        
        peliculaRepo.update(peli)
        print(peliculaRepo.get(id: 1)?.toString() ?? "")
        
        print(peli.genero.toString())
        print(peli.pais.toString())
        print(peli.director.toString())
    }
    
}
