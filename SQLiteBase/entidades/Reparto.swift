import Foundation

// Tabla puente N:M entre Pelicula y Actor
struct Reparto {
    var idPelicula: Int
    var idActor: Int
    var personaje: String
    var rol: String         // "Principal" o "Secundario"

    init(idPelicula: Int, idActor: Int, personaje: String, rol: String = "Secundario") {
        self.idPelicula = idPelicula
        self.idActor    = idActor
        self.personaje  = personaje
        self.rol        = rol
    }

    func toString() -> String {
        return """
        { "idPelicula": \(idPelicula), "idActor": \(idActor), "personaje": "\(personaje)", "rol": "\(rol)" }
        """
    }
}
