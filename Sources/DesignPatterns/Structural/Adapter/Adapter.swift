//
//  Adapter.swift
//  DesignPatterns
//
//  Created by Alex.personal on 26/8/25.
//

// MARK: - Simulación de un SDK externo (Firebase)
// El SDK de Firebase no devuelve directamente un String,
// sino un objeto más complejo (FirebaseJsonValue).
struct FirebaseJsonValue {
    let key: String
    let value: String
}

struct FirebaseSDK {
    func fetchValue(forKey key: String) -> FirebaseJsonValue {
        FirebaseJsonValue(key: key, value: "Valor desde Firebase para \(key)")
    }
}

// MARK: - Adapter: FirebaseRemoteConfig
// Este struct actúa como un ADAPTER entre el SDK de Firebase y la interfaz RemoteConfig.
// El cliente (AppConfig) espera un método `getValue(forKey:) -> String`.
// Sin embargo, el SDK expone `fetchValue(forKey:) -> FirebaseJsonValue`.
// El Adapter traduce la interfaz incompatible del SDK a la interfaz común que la app entiende.
struct FirebaseRemoteConfigAdapter: RemoteConfig {
    private let sdk = FirebaseSDK()

    func getValue(forKey key: String) -> String {
        // Aquí se hace la traducción: de FirebaseJsonValue -> String
        return sdk.fetchValue(forKey: key).value
    }
}

// MARK: - Otra implementación compatible sin necesidad de Adapter
// GrowthBook ya devuelve un String directamente, así que no hace falta adaptar nada.
// Simplemente conforma el protocolo RemoteConfig.
struct GrowthBookRemoteConfig: RemoteConfig {
    func getValue(forKey key: String) -> String {
        // Simula la obtención de un valor desde GrowthBook Remote Config
        return "Valor desde GrowthBook"
    }
}

// MARK: - Protocolo común que define la interfaz esperada por el cliente
// Cualquier proveedor de configuración remota debe implementar este contrato.
// Esto permite a AppConfig ser agnóstico del origen (Firebase, GrowthBook, etc.)
protocol RemoteConfig {
    func getValue(forKey key: String) -> String
}

// MARK: - Cliente
// AppConfig depende de la abstracción (RemoteConfig) y no de una implementación concreta.
// Gracias al Adapter, AppConfig puede usar Firebase aunque tenga una interfaz distinta.
struct AppConfig {
    private let remoteConfig: RemoteConfig

    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
    }

    func getFeatureFlag(forKey key: String) -> String {
        return remoteConfig.getValue(forKey: key)
    }
}

