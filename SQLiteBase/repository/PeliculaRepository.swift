import Foundation
import SQLite3

final class PeliculaRepository {

    private let db = DatabaseManager.shared

    // MARK: - GET por ID

    func get(id: Int) -> Pelicula? {
        let sql = """
            SELECT id_pelicula, titulo, anio, duracion_min,
                   id_genero, id_pais, id_director
            FROM Peliculas WHERE id_pelicula = ?;
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

    func getAll() -> [Pelicula] {
        let sql = """
            SELECT id_pelicula, titulo, anio, duracion_min,
                   id_genero, id_pais, id_director
            FROM Peliculas ORDER BY titulo;
            """
        guard let stmt = db.prepare(sql) else { return [] }
        defer { sqlite3_finalize(stmt) }

        var results: [Pelicula] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(mapRow(stmt))
        }
        return results
    }

    // MARK: - SAVE (INSERT)

    @discardableResult
    func save(_ pelicula: Pelicula) -> Int64 {
        let sql = """
            INSERT INTO Peliculas (titulo, anio, duracion_min, id_genero, id_pais, id_director)
            VALUES (?, ?, ?, ?, ?, ?);
            """
        guard let stmt = db.prepare(sql) else { return -1 }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, pelicula.titulo, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt,  2, Int32(pelicula.anio))
        sqlite3_bind_int(stmt,  3, Int32(pelicula.duracionMin))
        bindOptionalInt(stmt, index: 4, value: pelicula.idGenero)
        bindOptionalInt(stmt, index: 5, value: pelicula.idPais)
        bindOptionalInt(stmt, index: 6, value: pelicula.idDirector)

        if sqlite3_step(stmt) == SQLITE_DONE {
            return db.lastInsertedId
        }
        print("[PeliculaRepository] Error en save")
        return -1
    }

    // MARK: - UPDATE

    @discardableResult
    func update(_ pelicula: Pelicula) -> Bool {
        let sql = """
            UPDATE Peliculas
            SET titulo = ?, anio = ?, duracion_min = ?,
                id_genero = ?, id_pais = ?, id_director = ?
            WHERE id_pelicula = ?;
            """
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, pelicula.titulo, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt,  2, Int32(pelicula.anio))
        sqlite3_bind_int(stmt,  3, Int32(pelicula.duracionMin))
        bindOptionalInt(stmt, index: 4, value: pelicula.idGenero)
        bindOptionalInt(stmt, index: 5, value: pelicula.idPais)
        bindOptionalInt(stmt, index: 6, value: pelicula.idDirector)
        sqlite3_bind_int(stmt,  7, Int32(pelicula.idPelicula))

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - DELETE

    @discardableResult
    func delete(id: Int) -> Bool {
        let sql = "DELETE FROM Peliculas WHERE id_pelicula = ?;"
        guard let stmt = db.prepare(sql) else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int(stmt, 1, Int32(id))
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - Helpers

    private func mapRow(_ stmt: OpaquePointer) -> Pelicula {
        let id      = Int(sqlite3_column_int(stmt, 0))
        let titulo  = String(cString: sqlite3_column_text(stmt, 1))
        let anio    = Int(sqlite3_column_int(stmt, 2))
        let dur     = Int(sqlite3_column_int(stmt, 3))
        let genero  = sqlite3_column_type(stmt, 4) != SQLITE_NULL ? Int(sqlite3_column_int(stmt, 4)) : nil
        let pais    = sqlite3_column_type(stmt, 5) != SQLITE_NULL ? Int(sqlite3_column_int(stmt, 5)) : nil
        let dir     = sqlite3_column_type(stmt, 6) != SQLITE_NULL ? Int(sqlite3_column_int(stmt, 6)) : nil
        return Pelicula(idPelicula: id, titulo: titulo, anio: anio, duracionMin: dur,
                        idGenero: genero, idPais: pais, idDirector: dir)
    }

    private func bindOptionalInt(_ stmt: OpaquePointer, index: Int32, value: Int?) {
        if let value = value {
            sqlite3_bind_int(stmt, index, Int32(value))
        } else {
            sqlite3_bind_null(stmt, index)
        }
    }
}
