import Foundation

struct Director {
    var idDirector: Int
    var nombre: String
    var apellido: String
    var nacionalidad: String?

    init(idDirector: Int = 0, nombre: String, apellido: String, nacionalidad: String? = nil) {
        self.idDirector   = idDirector
        self.nombre       = nombre
        self.apellido     = apellido
        self.nacionalidad = nacionalidad
    }

    var nombreCompleto: String { "\(nombre) \(apellido)" }

    func toString() -> String {
        let nac = nacionalidad.map { "\"\($0)\"" } ?? "null"
        return """
        { "idDirector": \(idDirector), "nombre": "\(nombre)", "apellido": "\(apellido)", "nacionalidad": \(nac) }
        """
    }
}
