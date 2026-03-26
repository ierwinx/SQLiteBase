import Foundation

struct Pelicula {
    var idPelicula: Int
    var titulo: String
    var anio: Int
    var duracionMin: Int
    var idGenero: Int?
    var idPais: Int?
    var idDirector: Int?

    init(
        idPelicula: Int = 0,
        titulo: String,
        anio: Int,
        duracionMin: Int,
        idGenero: Int? = nil,
        idPais: Int? = nil,
        idDirector: Int? = nil
    ) {
        self.idPelicula  = idPelicula
        self.titulo      = titulo
        self.anio        = anio
        self.duracionMin = duracionMin
        self.idGenero    = idGenero
        self.idPais      = idPais
        self.idDirector  = idDirector
    }

    func toString() -> String {
        let genero   = idGenero.map   { String($0) } ?? "null"
        let pais     = idPais.map     { String($0) } ?? "null"
        let director = idDirector.map { String($0) } ?? "null"
        return """
        { "idPelicula": \(idPelicula), "titulo": "\(titulo)", "anio": \(anio), "duracionMin": \(duracionMin), "idGenero": \(genero), "idPais": \(pais), "idDirector": \(director) }
        """
    }
}
