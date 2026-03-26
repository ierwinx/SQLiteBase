import Foundation
import SQLite3

final class GeneroRepository {

    private let db = DatabaseManager.shared

    // MARK: - GET por ID

    func get(id: Int) -> Genero? {
        let sql = "SELECT id_genero, nombre, descripcion FROM Generos WHERE id_genero = ?;"
        guard let stmt = db.prepare(sql) else { return nil }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))

        if sqlite3_step(stmt) == SQLITE_ROW {
            return mapRow(stmt)
        }
        return nil
    }

    // MARK: - GET ALL

    func getAll() -> [Genero] {
        let sql = "SELECT id_genero, nombre, descripcion FROM Generos ORDER BY nombre;"
        guard let stmt = db.prepare(sql) else { return [] }
        defer { sqlite3_finalize(stmt) }

        var results: [Genero] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(mapRow(stmt))
        }
        return results
    }

    // MARK: - SAVE (INSERT)

    @discardableResult
    func save(_ genero: Genero) -> Int64 {
        let sql = "INSERT INTO Generos (nombre, descripcion) VALUES (?, ?);"
        guard let stmt = db.prepare(sql) else { return -1 }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, genero.nombre, -1, SQLITE_TRANSIENT)
        bindOptionalText(stmt, index: 2, value: genero.descripcion)

        if sqlite3_step(stmt) == SQLITE_DONE {
            return db.lastInsertedId
        }
        print("[GeneroRepository] Error en save")
        return -1
    }

    // MARK: - UPDATE

    @discardableResult
    func update(_ genero: Genero) -> Bool {
        let sql = "UPDATE Generos SET nombre = ?, descripcion = ? WHERE id_genero = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, genero.nombre, -1, SQLITE_TRANSIENT)
        bindOptionalText(stmt, index: 2, value: genero.descripcion)
        sqlite3_bind_int(stmt, 3, Int32(genero.idGenero))

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - DELETE

    @discardableResult
    func delete(id: Int) -> Bool {
        let sql = "DELETE FROM Generos WHERE id_genero = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - Helpers

    private func mapRow(_ stmt: OpaquePointer) -> Genero {
        let id     = Int(sqlite3_column_int(stmt, 0))
        let nombre = String(cString: sqlite3_column_text(stmt, 1))
        let desc   = sqlite3_column_text(stmt, 2).map { String(cString: $0) }
        return Genero(idGenero: id, nombre: nombre, descripcion: desc)
    }

    private func bindOptionalText(_ stmt: OpaquePointer, index: Int32, value: String?) {
        if let value = value {
            sqlite3_bind_text(stmt, index, value, -1, SQLITE_TRANSIENT)
        } else {
            sqlite3_bind_null(stmt, index)
        }
    }
}
