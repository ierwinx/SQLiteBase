import Foundation
import SQLite3

// SQLITE_TRANSIENT no es directamente accesible en Swift como macro de C.
// Esta constante global la expone para todos los repositorios.
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

// MARK: - DatabaseManager
// Singleton que gestiona la conexión y operaciones base con SQLite

final class DatabaseManager {

    static let shared = DatabaseManager()

    private var db: OpaquePointer?
    private let dbName = "Peliculas.db"

    // MARK: - Init

    private init() {
        db = openDatabase()
    }

    // MARK: - Conexión

    /// Copia la BD desde el bundle al directorio Documents (solo la primera vez)
    /// y abre la conexión.
    private func openDatabase() -> OpaquePointer? {
        let fileURL = documentsURL()

        // Copiar desde el bundle si no existe en Documents
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            if let bundleURL = Bundle.main.url(forResource: "Peliculas", withExtension: "db") {
                do {
                    try FileManager.default.copyItem(at: bundleURL, to: fileURL)
                } catch {
                    print("[DatabaseManager] Error copiando BD desde bundle: \(error)")
                }
            }
        }

        var pointer: OpaquePointer?
        if sqlite3_open(fileURL.path, &pointer) == SQLITE_OK {
            print("[DatabaseManager] Conexión abierta: \(fileURL.path)")
            enableForeignKeys(pointer)
            createTablesIfNeeded(pointer)
            return pointer
        } else {
            print("[DatabaseManager] Error al abrir la BD.")
            return nil
        }
    }

    /// Lee Peliculas.sql del bundle, extrae solo los CREATE TABLE y los ejecuta.
    private func createTablesIfNeeded(_ pointer: OpaquePointer?) {
        guard let sqlURL = Bundle.main.url(forResource: "Peliculas", withExtension: "sql"),
              let content = try? String(contentsOf: sqlURL, encoding: .utf8) else {
            print("[DatabaseManager] No se encontró Peliculas.sql en el bundle.")
            return
        }

        // Separar por ";" y quedarse solo con los CREATE TABLE
        let statements = content
            .components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.uppercased().hasPrefix("CREATE TABLE") }

        for statement in statements {
            var errMsg: UnsafeMutablePointer<CChar>?
            if sqlite3_exec(pointer, statement + ";", nil, nil, &errMsg) != SQLITE_OK {
                let msg = errMsg.map { String(cString: $0) } ?? "Desconocido"
                print("[DatabaseManager] Error creando tabla: \(msg)")
                sqlite3_free(errMsg)
            }
        }

        print("[DatabaseManager] Tablas verificadas/creadas desde Peliculas.sql (\(statements.count) tablas).")
    }

    private func documentsURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(dbName)
    }

    private func enableForeignKeys(_ pointer: OpaquePointer?) {
        sqlite3_exec(pointer, "PRAGMA foreign_keys = ON;", nil, nil, nil)
    }

    // MARK: - Acceso interno al puntero

    var connection: OpaquePointer? { db }

    // MARK: - Ejecutar sentencias (INSERT / UPDATE / DELETE / DDL)

    @discardableResult
    func execute(_ sql: String) -> Bool {
        var errMsg: UnsafeMutablePointer<CChar>?
        let result = sqlite3_exec(db, sql, nil, nil, &errMsg)
        if result != SQLITE_OK {
            let msg = errMsg.map { String(cString: $0) } ?? "Desconocido"
            print("[DatabaseManager] Error ejecutando SQL: \(msg)")
            sqlite3_free(errMsg)
            return false
        }
        return true
    }

    // MARK: - Preparar statement

    func prepare(_ sql: String) -> OpaquePointer? {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("[DatabaseManager] Error preparando: \(sql)")
            return nil
        }
        return stmt
    }

    // MARK: - Último ID insertado

    var lastInsertedId: Int64 {
        sqlite3_last_insert_rowid(db)
    }

    // MARK: - Cerrar conexión

    func close() {
        if let db = db {
            sqlite3_close(db)
            print("[DatabaseManager] Conexión cerrada.")
        }
        db = nil
    }

    deinit { close() }
}
