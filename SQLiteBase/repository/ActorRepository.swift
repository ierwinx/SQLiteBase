import Foundation
import SQLite3

final class ActorRepository {

    private let db = DatabaseManager.shared

    // MARK: - GET por ID

    func get(id: Int) -> Artista? {
        let sql = "SELECT id_actor, nombre, apellido, fecha_nac FROM Actores WHERE id_actor = ?;"
        guard let stmt = db.prepare(sql) else { return nil }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))

        if sqlite3_step(stmt) == SQLITE_ROW {
            return mapRow(stmt)
        }
        return nil
    }

    // MARK: - GET ALL

    func getAll() -> [Artista] {
        let sql = "SELECT id_actor, nombre, apellido, fecha_nac FROM Actores ORDER BY apellido;"
        guard let stmt = db.prepare(sql) else { return [] }
        defer { sqlite3_finalize(stmt) }

        var results: [Artista] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(mapRow(stmt))
        }
        return results
    }

    // MARK: - SAVE (INSERT)

    @discardableResult
    func save(_ artista: Artista) -> Int64 {
        let sql = "INSERT INTO Actores (nombre, apellido, fecha_nac) VALUES (?, ?, ?);"
        guard let stmt = db.prepare(sql) else { return -1 }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, artista.nombre,   -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, artista.apellido, -1, SQLITE_TRANSIENT)
        bindOptionalText(stmt, index: 3, value: artista.fechaNac)

        if sqlite3_step(stmt) == SQLITE_DONE {
            return db.lastInsertedId
        }
        print("[ActorRepository] Error en save")
        return -1
    }

    // MARK: - UPDATE

    @discardableResult
    func update(_ artista: Artista) -> Bool {
        let sql = "UPDATE Actores SET nombre = ?, apellido = ?, fecha_nac = ? WHERE id_actor = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, artista.nombre,   -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, artista.apellido, -1, SQLITE_TRANSIENT)
        bindOptionalText(stmt, index: 3, value: artista.fechaNac)
        sqlite3_bind_int(stmt, 4, Int32(artista.idActor))

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - DELETE

    @discardableResult
    func delete(id: Int) -> Bool {
        let sql = "DELETE FROM Actores WHERE id_actor = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - Helpers

    private func mapRow(_ stmt: OpaquePointer) -> Artista {
        let id     = Int(sqlite3_column_int(stmt, 0))
        let nombre = String(cString: sqlite3_column_text(stmt, 1))
        let apell  = String(cString: sqlite3_column_text(stmt, 2))
        let fecha  = sqlite3_column_text(stmt, 3).map { String(cString: $0) }
        return Artista(idActor: id, nombre: nombre, apellido: apell, fechaNac: fecha)
    }

    private func bindOptionalText(_ stmt: OpaquePointer, index: Int32, value: String?) {
        if let value = value {
            sqlite3_bind_text(stmt, index, value, -1, SQLITE_TRANSIENT)
        } else {
            sqlite3_bind_null(stmt, index)
        }
    }
}
