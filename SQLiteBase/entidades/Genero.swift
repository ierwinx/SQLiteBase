import Foundation

struct Genero {
    var idGenero: Int
    var nombre: String
    var descripcion: String?

    init(idGenero: Int = 0, nombre: String, descripcion: String? = nil) {
        self.idGenero    = idGenero
        self.nombre      = nombre
        self.descripcion = descripcion
    }

    func toString() -> String {
        let desc = descripcion.map { "\"\($0)\"" } ?? "null"
        return """
        { "idGenero": \(idGenero), "nombre": "\(nombre)", "descripcion": \(desc) }
        """
    }
}
