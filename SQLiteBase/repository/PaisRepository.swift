import Foundation
import SQLite3

final class PaisRepository {

    private let db = DatabaseManager.shared

    // MARK: - GET por ID

    func get(id: Int) -> Pais? {
        let sql = "SELECT id_pais, nombre, codigo FROM Paises WHERE id_pais = ?;"
        guard let stmt = db.prepare(sql) else { return nil }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))

        if sqlite3_step(stmt) == SQLITE_ROW {
            return mapRow(stmt)
        }
        return nil
    }

    // MARK: - GET ALL

    func getAll() -> [Pais] {
        let sql = "SELECT id_pais, nombre, codigo FROM Paises ORDER BY nombre;"
        guard let stmt = db.prepare(sql) else { return [] }
        defer { sqlite3_finalize(stmt) }

        var results: [Pais] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(mapRow(stmt))
        }
        return results
    }

    // MARK: - SAVE (INSERT)

    @discardableResult
    func save(_ pais: Pais) -> Int64 {
        let sql = "INSERT INTO Paises (nombre, codigo) VALUES (?, ?);"
        guard let stmt = db.prepare(sql) else { return -1 }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, pais.nombre, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, pais.codigo, -1, SQLITE_TRANSIENT)

        if sqlite3_step(stmt) == SQLITE_DONE {
            return db.lastInsertedId
        }
        print("[PaisRepository] Error en save")
        return -1
    }

    // MARK: - UPDATE

    @discardableResult
    func update(_ pais: Pais) -> Bool {
        let sql = "UPDATE Paises SET nombre = ?, codigo = ? WHERE id_pais = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, pais.nombre, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, pais.codigo, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 3, Int32(pais.idPais))

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - DELETE

    @discardableResult
    func delete(id: Int) -> Bool {
        let sql = "DELETE FROM Paises WHERE id_pais = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - Helpers

    private func mapRow(_ stmt: OpaquePointer) -> Pais {
        let id     = Int(sqlite3_column_int(stmt, 0))
        let nombre = String(cString: sqlite3_column_text(stmt, 1))
        let codigo = String(cString: sqlite3_column_text(stmt, 2))
        return Pais(idPais: id, nombre: nombre, codigo: codigo)
    }
}
