import Foundation

struct Pais {
    var idPais: Int
    var nombre: String
    var codigo: String

    init(idPais: Int = 0, nombre: String, codigo: String) {
        self.idPais  = idPais
        self.nombre  = nombre
        self.codigo  = codigo
    }

    func toString() -> String {
        return """
        { "idPais": \(idPais), "nombre": "\(nombre)", "codigo": "\(codigo)" }
        """
    }
}
