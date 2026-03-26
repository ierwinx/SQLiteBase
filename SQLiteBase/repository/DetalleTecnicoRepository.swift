import Foundation
import SQLite3

final class DetalleTecnicoRepository {

    private let db = DatabaseManager.shared

    // MARK: - GET por ID (= id de la película)

    func get(id: Int) -> DetalleTecnico? {
        let sql = """
            SELECT id_detalle, resolucion, formato_audio, subtitulos, clasificacion
            FROM DetallesTecnicos WHERE id_detalle = ?;
            """
        guard let stmt = db.prepare(sql) else { return nil }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))

        if sqlite3_step(stmt) == SQLITE_ROW {
            return mapRow(stmt)
        }
        return nil
    }

    // MARK: - GET ALL

    func getAll() -> [DetalleTecnico] {
        let sql = """
            SELECT id_detalle, resolucion, formato_audio, subtitulos, clasificacion
            FROM DetallesTecnicos ORDER BY id_detalle;
            """
        guard let stmt = db.prepare(sql) else { return [] }
        defer { sqlite3_finalize(stmt) }

        var results: [DetalleTecnico] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(mapRow(stmt))
        }
        return results
    }

    // MARK: - SAVE (INSERT)
    // id_detalle debe coincidir con un id_pelicula existente (relación 1:1)

    @discardableResult
    func save(_ detalle: DetalleTecnico) -> Bool {
        let sql = """
            INSERT INTO DetallesTecnicos (id_detalle, resolucion, formato_audio, subtitulos, clasificacion)
            VALUES (?, ?, ?, ?, ?);
            """
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt,  1, Int32(detalle.idDetalle))
        sqlite3_bind_text(stmt, 2, detalle.resolucion,   -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, detalle.formatoAudio, -1, SQLITE_TRANSIENT)
        bindOptionalText(stmt, index: 4, value: detalle.subtitulos)
        sqlite3_bind_text(stmt, 5, detalle.clasificacion, -1, SQLITE_TRANSIENT)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - UPDATE

    @discardableResult
    func update(_ detalle: DetalleTecnico) -> Bool {
        let sql = """
            UPDATE DetallesTecnicos
            SET resolucion = ?, formato_audio = ?, subtitulos = ?, clasificacion = ?
            WHERE id_detalle = ?;
            """
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, detalle.resolucion,    -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, detalle.formatoAudio,  -1, SQLITE_TRANSIENT)
        bindOptionalText(stmt, index: 3, value: detalle.subtitulos)
        sqlite3_bind_text(stmt, 4, detalle.clasificacion, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt,  5, Int32(detalle.idDetalle))

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - DELETE

    @discardableResult
    func delete(id: Int) -> Bool {
        let sql = "DELETE FROM DetallesTecnicos WHERE id_detalle = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - Helpers

    private func mapRow(_ stmt: OpaquePointer) -> DetalleTecnico {
        let id     = Int(sqlite3_column_int(stmt, 0))
        let res    = String(cString: sqlite3_column_text(stmt, 1))
        let audio  = String(cString: sqlite3_column_text(stmt, 2))
        let subs   = sqlite3_column_text(stmt, 3).map { String(cString: $0) }
        let clasif = String(cString: sqlite3_column_text(stmt, 4))
        return DetalleTecnico(idDetalle: id, resolucion: res, formatoAudio: audio,
                              subtitulos: subs, clasificacion: clasif)
    }

    private func bindOptionalText(_ stmt: OpaquePointer, index: Int32, value: String?) {
        if let value = value {
            sqlite3_bind_text(stmt, index, value, -1, SQLITE_TRANSIENT)
        } else {
            sqlite3_bind_null(stmt, index)
        }
    }
}
