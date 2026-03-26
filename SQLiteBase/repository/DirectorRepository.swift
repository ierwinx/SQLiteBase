import Foundation
import SQLite3

final class DirectorRepository {

    private let db = DatabaseManager.shared

    // MARK: - GET por ID

    func get(id: Int) -> Director? {
        let sql = "SELECT id_director, nombre, apellido, nacionalidad FROM Directores WHERE id_director = ?;"
        guard let stmt = db.prepare(sql) else { return nil }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))

        if sqlite3_step(stmt) == SQLITE_ROW {
            return mapRow(stmt)
        }
        return nil
    }

    // MARK: - GET ALL

    func getAll() -> [Director] {
        let sql = "SELECT id_director, nombre, apellido, nacionalidad FROM Directores ORDER BY apellido;"
        guard let stmt = db.prepare(sql) else { return [] }
        defer { sqlite3_finalize(stmt) }

        var results: [Director] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(mapRow(stmt))
        }
        return results
    }

    // MARK: - SAVE (INSERT)

    @discardableResult
    func save(_ director: Director) -> Int64 {
        let sql = "INSERT INTO Directores (nombre, apellido, nacionalidad) VALUES (?, ?, ?);"
        guard let stmt = db.prepare(sql) else { return -1 }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, director.nombre,    -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, director.apellido,  -1, SQLITE_TRANSIENT)
        bindOptionalText(stmt, index: 3, value: director.nacionalidad)

        if sqlite3_step(stmt) == SQLITE_DONE {
            return db.lastInsertedId
        }
        print("[DirectorRepository] Error en save")
        return -1
    }

    // MARK: - UPDATE

    @discardableResult
    func update(_ director: Director) -> Bool {
        let sql = "UPDATE Directores SET nombre = ?, apellido = ?, nacionalidad = ? WHERE id_director = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, director.nombre,   -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, director.apellido, -1, SQLITE_TRANSIENT)
        bindOptionalText(stmt, index: 3, value: director.nacionalidad)
        sqlite3_bind_int(stmt, 4, Int32(director.idDirector))

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - DELETE

    @discardableResult
    func delete(id: Int) -> Bool {
        let sql = "DELETE FROM Directores WHERE id_director = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - Helpers

    private func mapRow(_ stmt: OpaquePointer) -> Director {
        let id     = Int(sqlite3_column_int(stmt, 0))
        let nombre = String(cString: sqlite3_column_text(stmt, 1))
        let apell  = String(cString: sqlite3_column_text(stmt, 2))
        let nac    = sqlite3_column_text(stmt, 3).map { String(cString: $0) }
        return Director(idDirector: id, nombre: nombre, apellido: apell, nacionalidad: nac)
    }

    private func bindOptionalText(_ stmt: OpaquePointer, index: Int32, value: String?) {
        if let value = value {
            sqlite3_bind_text(stmt, index, value, -1, SQLITE_TRANSIENT)
        } else {
            sqlite3_bind_null(stmt, index)
        }
    }
}
