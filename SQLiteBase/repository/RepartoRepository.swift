import Foundation
import SQLite3

final class RepartoRepository {

    private let db = DatabaseManager.shared

    // MARK: - GET por ID compuesto (id_pelicula + id_actor)

    func get(idPelicula: Int, idActor: Int) -> Reparto? {
        let sql = """
            SELECT id_pelicula, id_actor, personaje, rol
            FROM Reparto WHERE id_pelicula = ? AND id_actor = ?;
            """
        guard let stmt = db.prepare(sql) else { return nil }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(idPelicula))

        if sqlite3_step(stmt) == SQLITE_ROW {
            return mapRow(stmt)
        }
        return nil
    }

    // MARK: - GET ALL

    func getAll() -> [Reparto] {
        let sql = "SELECT id_pelicula, id_actor, personaje, rol FROM Reparto ORDER BY id_pelicula, id_actor;"
        guard let stmt = db.prepare(sql) else { return [] }
        defer { sqlite3_finalize(stmt) }

        var results: [Reparto] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(mapRow(stmt))
        }
        return results
    }

    // MARK: - GET por Película (actores de una película)

    func getByPelicula(idPelicula: Int) -> [Reparto] {
        let sql = """
            SELECT id_pelicula, id_actor, personaje, rol
            FROM Reparto WHERE id_pelicula = ? ORDER BY rol;
            """
        guard let stmt = db.prepare(sql) else { return [] }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(idPelicula))

        var results: [Reparto] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(mapRow(stmt))
        }
        return results
    }

    // MARK: - GET por Actor (películas de un actor)

    func getByActor(idActor: Int) -> [Reparto] {
        let sql = """
            SELECT id_pelicula, id_actor, personaje, rol
            FROM Reparto WHERE id_actor = ? ORDER BY id_pelicula;
            """
        guard let stmt = db.prepare(sql) else { return [] }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(idActor))

        var results: [Reparto] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(mapRow(stmt))
        }
        return results
    }

    // MARK: - SAVE (INSERT)

    @discardableResult
    func save(_ reparto: Reparto) -> Bool {
        let sql = """
            INSERT INTO Reparto (id_pelicula, id_actor, personaje, rol)
            VALUES (?, ?, ?, ?);
            """
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt,  1, Int32(reparto.idPelicula))
        sqlite3_bind_int(stmt,  2, Int32(reparto.idActor))
        sqlite3_bind_text(stmt, 3, reparto.personaje, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 4, reparto.rol,       -1, SQLITE_TRANSIENT)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - UPDATE

    @discardableResult
    func update(_ reparto: Reparto) -> Bool {
        let sql = """
            UPDATE Reparto SET personaje = ?, rol = ?
            WHERE id_pelicula = ? AND id_actor = ?;
            """
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, reparto.personaje,     -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, reparto.rol,           -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt,  3, Int32(reparto.idPelicula))
        sqlite3_bind_int(stmt,  4, Int32(reparto.idActor))

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - DELETE por ID compuesto

    @discardableResult
    func delete(idPelicula: Int, idActor: Int) -> Bool {
        let sql = "DELETE FROM Reparto WHERE id_pelicula = ? AND id_actor = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(idPelicula))
        sqlite3_bind_int(stmt, 2, Int32(idActor))
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - Helpers

    private func mapRow(_ stmt: OpaquePointer) -> Reparto {
        let idPel  = Int(sqlite3_column_int(stmt, 0))
        let idAct  = Int(sqlite3_column_int(stmt, 1))
        let pers   = String(cString: sqlite3_column_text(stmt, 2))
        let rol    = String(cString: sqlite3_column_text(stmt, 3))
        return Reparto(idPelicula: idPel, idActor: idAct, personaje: pers, rol: rol)
    }
}
