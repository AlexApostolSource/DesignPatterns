//
//  MediatorKata_LoginDialog.swift
//  DesignPatternsShowCase
//
//  Kata de Mediator (punto de partida "malo") — Login Dialog (con OTP opcional).
//  Objetivo: desacoplar componentes (colegas) y centralizar la coordinación en un Mediator.
//
//  Instrucciones:
//  - Observa el código “malo”: los componentes se conocen entre sí y se actualizan directamente.
//  - Refactoriza a Mediator:
//    1) Define un protocolo Mediator (p.ej. DialogMediator) con notify(sender:event:).
//    2) Haz que los componentes (TextField, Checkbox, Button) no se conozcan entre sí;
//       sólo notifican eventos al Mediator.
//    3) Implementa un ConcreteMediator (LoginDialogMediator) que contenga la lógica de habilitar
//       botones, mostrar/ocultar labels y limpiar campos.
//    4) Mantén el mismo comportamiento observable (mismo output en el #Playground).
//
//  Sugerencias de eventos: .changedText, .toggled(Bool), .tapped
//

import Foundation
import Playgrounds

// MARK: - Componentes (simples, estilo UI mínima)

final class TextField: CustomStringConvertible {
	let id: String
	private(set) var text: String
	var isEnabled: Bool
	var isHidden: Bool
	let isSecure: Bool
	var onChange: ((String) -> Void)?

	init(id: String, text: String = "", isEnabled: Bool = true, isHidden: Bool = false, isSecure: Bool = false) {
		self.id = id
		self.text = text
		self.isEnabled = isEnabled
		self.isHidden = isHidden
		self.isSecure = isSecure
	}

	func setText(_ newValue: String) {
		guard isEnabled else {
			print("TextField[\(id)] está deshabilitado; ignorando setText")
			return
		}
		text = newValue
		print("TextField[\(id)] -> '\(isSecure ? String(repeating: "•", count: text.count) : text)'")
		onChange?(text)
	}

	var description: String {
		let value = isSecure ? String(repeating: "•", count: text.count) : text
		return "TextField(\(id), text:'\(value)', enabled:\(isEnabled), hidden:\(isHidden))"
	}
}

final class Checkbox: CustomStringConvertible {
	let id: String
	private(set) var isChecked: Bool
	var isEnabled: Bool
	var onToggle: ((Bool) -> Void)?

	init(id: String, isChecked: Bool = false, isEnabled: Bool = true) {
		self.id = id
		self.isChecked = isChecked
		self.isEnabled = isEnabled
	}

	func setChecked(_ newValue: Bool) {
		guard isEnabled else {
			print("Checkbox[\(id)] está deshabilitado; ignorando toggle")
			return
		}
		isChecked = newValue
		print("Checkbox[\(id)] -> \(isChecked ? "ON" : "OFF")")
		onToggle?(isChecked)
	}

	func toggle() { setChecked(!isChecked) }

	var description: String {
		"Checkbox(\(id), checked:\(isChecked), enabled:\(isEnabled))"
	}
}

final class Button: CustomStringConvertible {
	let id: String
	var isEnabled: Bool
	var isHidden: Bool
	var onTap: (() -> Void)?

	init(id: String, isEnabled: Bool = false, isHidden: Bool = false) {
		self.id = id
		self.isEnabled = isEnabled
		self.isHidden = isHidden
	}

	func tap() {
		print("Button[\(id)] tap")
		guard isEnabled else {
			print("  (ignorado: botón deshabilitado)")
			return
		}
		onTap?()
	}

	var description: String {
		"Button(\(id), enabled:\(isEnabled), hidden:\(isHidden))"
	}
}

final class Label: CustomStringConvertible {
	let id: String
	var text: String
	var isHidden: Bool

	init(id: String, text: String, isHidden: Bool = true) {
		self.id = id
		self.text = text
		self.isHidden = isHidden
	}

	var description: String {
		"Label(\(id), text:'\(text)', hidden:\(isHidden))"
	}
}

// MARK: - Código "malo" (sin Mediator)
// Problemas intencionados:
// - Acoplamiento fuerte: los componentes se conocen directamente.
// - Lógica de coordinación dispersa en closures.
// - Dificulta añadir/quitar reglas sin romper dependencias.
// - Botones/labels se actualizan desde múltiples sitios (riesgo de inconsistencias).

final class LoginDialogBad {

	// Controles
	let usernameField = TextField(id: "username")
	let passwordField = TextField(id: "password", isSecure: true)
	let otpField      = TextField(id: "otp", isHidden: true)
	let rememberMe    = Checkbox(id: "rememberMe")
	let useOTP        = Checkbox(id: "useOTP")

	let privacyWarning = Label(id: "privacy", text: "Guardaremos tus credenciales localmente", isHidden: true)
	let resetBanner    = Label(id: "resetBanner", text: "Proceso de recuperación iniciado", isHidden: true)

	let loginButton         = Button(id: "login", isEnabled: false)
	let forgotPasswordButton = Button(id: "forgot", isEnabled: true)

	// Estado adicional “oculto” en el diálogo
	private var lockedOut = false

	init() {
		// Wiring directo (malo): cada control conoce y toca a otros.
		usernameField.onChange = { [weak self] _ in
			self?.updateLoginEnabled()
		}
		passwordField.onChange = { [weak self] _ in
			self?.updateLoginEnabled()
		}
		otpField.onChange = { [weak self] _ in
			self?.updateLoginEnabled()
		}
		useOTP.onToggle = { [weak self] checked in
			guard let self else { return }
			self.otpField.isHidden = !checked
			print("OTP Field ahora está \(self.otpField.isHidden ? "oculto" : "visible")")
			self.updateLoginEnabled()
		}
		rememberMe.onToggle = { [weak self] checked in
			guard let self else { return }
			self.privacyWarning.isHidden = !checked
			print("Privacy Warning \(self.privacyWarning.isHidden ? "oculto" : "visible")")
		}
		forgotPasswordButton.onTap = { [weak self] in
			guard let self else { return }
			print("Iniciando recuperación de contraseña…")
			self.passwordField.setText("")
			self.otpField.setText("")
			self.resetBanner.isHidden = false
			self.loginButton.isEnabled = false
		}
		loginButton.onTap = { [weak self] in
			guard let self else { return }
			print("Intentando login para '\(self.usernameFieldTextForLog())'…")
			if self.lockedOut {
				print("Cuenta bloqueada. Intenta más tarde.")
				return
			}
			// Simulación de validación; si OTP está activo, debe ser de 6 dígitos.
			let okUser = !self.usernameFieldText().isEmpty
			let okPass = self.passwordFieldText().count >= 6
			let okOTP  = self.useOTPChecked() ? self.otpFieldText().count == 6 : true

			if okUser && okPass && okOTP {
				print("Login OK ✅")
				self.resetBanner.isHidden = true
			} else {
				print("Login falló ❌")
				// Bloqueo simple si se intenta con credenciales inválidas dos veces seguidas
				self.failedAttempts += 1
				if self.failedAttempts >= 2 {
					self.lockedOut = true
					print("Demasiados intentos. Cuenta bloqueada.")
				}
			}
			self.updateLoginEnabled()
		}
	}

	private var failedAttempts = 0

	// Lógica de habilitación del botón, repartida y duplicada (malo).
	private func updateLoginEnabled() {
		let hasUser = !usernameFieldText().isEmpty
		let hasPass = passwordFieldText().count >= 6
		let otpOK   = useOTPChecked() ? otpFieldText().count == 6 : true
		loginButton.isEnabled = hasUser && hasPass && otpOK && !lockedOut
		print("LoginButton.enabled = \(loginButton.isEnabled)")
	}

	// Accesores que exponen detalles internos (malo).
	private func usernameFieldText() -> String { usernameFieldTextForLog() }
	private func usernameFieldTextForLog() -> String { usernameFieldTextRaw() }
	private func usernameFieldTextRaw() -> String { usernameFieldTextReallyRaw() }
	private func usernameFieldTextReallyRaw() -> String { usernameFieldTextDeepRaw() }
	private func usernameFieldTextDeepRaw() -> String { usernameFieldTextDeepestRaw() }
	private func usernameFieldTextDeepestRaw() -> String { usernameField.description.contains("username") ? usernameFieldTextValue() : "" }
	private func usernameFieldTextValue() -> String { Mirror(reflecting: usernameField).children.first(where: { $0.label == "text" })?.value as? String ?? "" }

	private func passwordFieldText() -> String { Mirror(reflecting: passwordField).children.first(where: { $0.label == "text" })?.value as? String ?? "" }
	private func otpFieldText() -> String { Mirror(reflecting: otpField).children.first(where: { $0.label == "text" })?.value as? String ?? "" }
	private func useOTPChecked() -> Bool { Mirror(reflecting: useOTP).children.first(where: { $0.label == "isChecked" })?.value as? Bool ?? false }

	// Dump del estado de la UI
	func dumpUI() {
		func masked(_ s: String) -> String { String(repeating: "•", count: s.count) }
		let user = usernameFieldText()
		let pass = passwordFieldText()
		let otp  = otpFieldText()
		print("""
		— Estado UI —
		user: '\(user)'
		pass: '\(masked(pass))' (len=\(pass.count))
		otp:  '\(otp)' (hidden: \(otpField.isHidden))
		rememberMe: \(rememberMe.description)
		useOTP:     \(useOTP.description)
		privacy:    \(privacyWarning.description)
		reset:      \(resetBanner.description)
		login:      \(loginButton.description)
		forgot:     \(forgotPasswordButton.description)
		lockedOut:  \(lockedOut)
		""")
	}
}

// MARK: - TODO (tu trabajo)
// 1) Crea un protocolo Mediator, p.ej.:
//
//    protocol DialogMediator {
//        func notify(sender: AnyObject, event: DialogEvent)
//    }
//
//    enum DialogEvent {
//        case changedText(String)
//        case toggled(Bool)
//        case tapped
//    }
//
// 2) Haz que TextField/Checkbox/Button no conozcan a otros componentes.
//    - En lugar de closures que tocan otros controles, notifica al Mediator.
//    - Proporciona una interfaz mínima para que el Mediator pueda setText/setEnabled/show/hide.
// 3) Implementa LoginDialogMediator con la lógica de:
//    - Habilitar login cuando user != "" && pass.count >= 6 && (OTP off || otp.count == 6) && !lockedOut.
//    - Mostrar/ocultar OTP y Privacy Warning.
//    - “Forgot” limpia pass/otp, deshabilita login y muestra resetBanner.
//    - “Login” valida y, si falla dos veces, bloquea la cuenta.
// 4) Mantén el mismo comportamiento observable en el Playground (mismo output).

// MARK: - Demo (debe seguir funcionando tras el refactor)

#Playground {
	let dialog = LoginDialogBad()

	print("Escenario 1: Estado inicial")
	dialog.dumpUI()

	print("\nEscenario 2: Usuario escribe 'alice' y contraseña corta '123'")
	dialog.usernameField.setText("alice")
	dialog.passwordField.setText("123")
	dialog.dumpUI()

	print("\nEscenario 3: Usuario completa contraseña '123456'")
	dialog.passwordField.setText("123456")
	dialog.dumpUI()

	print("\nEscenario 4: Activa Remember Me")
	dialog.rememberMe.toggle()
	dialog.dumpUI()

	print("\nEscenario 5: Activa OTP")
	dialog.useOTP.setChecked(true)
	dialog.dumpUI()

	print("\nEscenario 6: Ingresa OTP '654321'")
	dialog.otpField.setText("654321")
	dialog.dumpUI()

	print("\nEscenario 7: Tap en Login")
	dialog.loginButton.tap()
	dialog.dumpUI()

	print("\nEscenario 8: Tap en Forgot Password")
	dialog.forgotPasswordButton.tap()
	dialog.dumpUI()
}
