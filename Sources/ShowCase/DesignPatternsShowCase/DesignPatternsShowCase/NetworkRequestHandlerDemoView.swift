// NetworkRequestHandlerDemoView.swift
import SwiftUI

struct NetworkRequestHandlerDemoView: View {
	@State private var hasNetwork: Bool = true
	@State private var token: String = "abc123"
	@State private var isPayloadValid: Bool = true
	@State private var isCached: Bool = false

	private let factory = NetworkRequestHandlerFactory()

	var body: some View {
		Form {
			Section(header: Text("Parámetros de la petición")) {
				Toggle("Conectividad", isOn: $hasNetwork)
				Toggle("Payload válido", isOn: $isPayloadValid)
				Toggle("Respuesta en caché", isOn: $isCached)
				HStack {
					Text("Token")
					Spacer()
					TextField("Opcional", text: $token)
						.multilineTextAlignment(.trailing)
						.textInputAutocapitalization(.never)
						.disableAutocorrection(true)
						.frame(minWidth: 120)
				}
			}

			Section(footer: Text("Los logs del procesamiento se muestran en la consola.")) {
				Button {
					runChain()
				} label: {
					Text("Ejecutar cadena")
						.frame(maxWidth: .infinity)
				}
			}
		}
	}

	private func runChain() {
		let request = HTTPRequest(
			hasNetwork: hasNetwork,
			token: token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : token,
			isPayloadValid: isPayloadValid,
			isCached: isCached
		)
		let handler = factory.make()
		handler.handle(request: request)
	}
}
