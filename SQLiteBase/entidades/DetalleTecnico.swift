import Foundation

// Relación 1:1 con Pelicula — comparte el mismo id_pelicula
struct DetalleTecnico {
    var idDetalle: Int        // mismo valor que id_pelicula
    var resolucion: String
    var formatoAudio: String
    var subtitulos: String?
    var clasificacion: String

    init(
        idDetalle: Int,
        resolucion: String,
        formatoAudio: String,
        subtitulos: String? = nil,
        clasificacion: String
    ) {
        self.idDetalle     = idDetalle
        self.resolucion    = resolucion
        self.formatoAudio  = formatoAudio
        self.subtitulos    = subtitulos
        self.clasificacion = clasificacion
    }

    func toString() -> String {
        let subs = subtitulos.map { "\"\($0)\"" } ?? "null"
        return """
        { "idDetalle": \(idDetalle), "resolucion": "\(resolucion)", "formatoAudio": "\(formatoAudio)", "subtitulos": \(subs), "clasificacion": "\(clasificacion)" }
        """
    }
}
