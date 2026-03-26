import Foundation

// Renombrado a Artista para evitar conflicto con el protocolo Actor de Swift concurrency
struct Artista {
    var idActor: Int
    var nombre: String
    var apellido: String
    var fechaNac: String?   // formato YYYY-MM-DD

    init(idActor: Int = 0, nombre: String, apellido: String, fechaNac: String? = nil) {
        self.idActor   = idActor
        self.nombre    = nombre
        self.apellido  = apellido
        self.fechaNac  = fechaNac
    }

    var nombreCompleto: String { "\(nombre) \(apellido)" }

    func toString() -> String {
        let fecha = fechaNac.map { "\"\($0)\"" } ?? "null"
        return """
        { "idActor": \(idActor), "nombre": "\(nombre)", "apellido": "\(apellido)", "fechaNac": \(fecha) }
        """
    }
}
