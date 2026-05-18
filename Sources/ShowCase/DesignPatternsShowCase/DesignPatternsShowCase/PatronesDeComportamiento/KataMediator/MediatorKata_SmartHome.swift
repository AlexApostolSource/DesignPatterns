//
//  MediatorKata_SmartHome.swift
//  DesignPatternsShowCase
//
//  Kata de Mediator (punto de partida "malo") — Smart Home.
//  Objetivo: desacoplar sensores/actuadores y centralizar la coordinación (modos,
//  alarmas, luces, termostato) en un Mediator.
//
//  Instrucciones:
//  - Observa el código “malo”: los dispositivos se conocen entre sí y aplican reglas duplicadas.
//  - Refactoriza a Mediator:
//    1) Define SmartHomeMediator (p.ej. notify(sender:event:) o métodos explícitos).
//    2) Haz que los dispositivos no conozcan a sus peers; solo notifiquen al Mediator.
//    3) Implementa HomeHubMediator con la lógica de modos (away/night), luces, alarma y termostato.
//    4) Mantén el mismo output observable del #Playground.
//
//  Retos extra:
//  - Escenas (arrival/bedtime) y prioridades de eventos.
//  - Temporizadores para auto‑apagado de luces tras X segundos sin movimiento.
//  - Habitaciones múltiples y grupos de dispositivos.
//  - Historial de eventos (Observer/Memento).
//

import Foundation
import Playgrounds

// MARK: - Código “malo” (sin Mediator)
// Problemas intencionados:
// - Acoplamiento fuerte entre componentes (sensores conocen luces/alarma/modos).
// - Lógica de coordinación dispersa y duplicada (sensores y modos tocan luces/alarma).
// - Difícil añadir reglas sin romper dependencias.

final class LightBad: CustomStringConvertible {
	let id: String
	private(set) var isOn: Bool = false

	init(id: String) { self.id = id }

	func setOn(_ on: Bool) {
		isOn = on
		print("💡 Light[\(id)] -> \(on ? "ON" : "OFF")")
	}

	var description: String { "Light(\(id), on:\(isOn))" }
}

final class ThermostatBad: CustomStringConvertible {
	private(set) var target: Int
	private(set) var ecoMode: Bool = false

	init(target: Int) { self.target = target }

	func setTarget(_ t: Int) {
		target = t
		print("🌡️ Thermostat target -> \(t)°C")
	}

	func setEcoMode(_ enabled: Bool) {
		ecoMode = enabled
		print("🌱 EcoMode -> \(enabled ? "ON" : "OFF")")
	}

	var description: String { "Thermostat(target:\(target), eco:\(ecoMode))" }
}

final class AlarmBad: CustomStringConvertible {
	private(set) var isArmed: Bool = false

	func arm() {
		isArmed = true
		print("🔔 Alarm ARMED")
	}

	func disarm() {
		isArmed = false
		print("🔕 Alarm DISARMED")
	}

	func alert(_ reason: String) {
		if isArmed {
			print("🚨 Alarm TRIGGERED — \(reason)")
		} else {
			print("🚨 Alarm ignored (disarmed) — \(reason)")
		}
	}

	var description: String { "Alarm(armed:\(isArmed))" }
}

final class ModeCenterBad: CustomStringConvertible {
	private(set) var awayMode: Bool = false
	private(set) var nightMode: Bool = false

	private let alarm: AlarmBad
	private let thermostat: ThermostatBad
	private let lights: [LightBad]

	init(alarm: AlarmBad, thermostat: ThermostatBad, lights: [LightBad]) {
		self.alarm = alarm
		self.thermostat = thermostat
		self.lights = lights
	}

	func setAway(_ enabled: Bool) {
		awayMode = enabled
		print("🏠 Mode: Away -> \(enabled ? "ON" : "OFF")")
		if enabled {
			alarm.arm()
			thermostat.setEcoMode(true)
			for l in lights { l.setOn(false) }
		} else {
			alarm.disarm()
			thermostat.setEcoMode(false)
		}
	}

	func setNight(_ enabled: Bool) {
		nightMode = enabled
		print("🌙 Mode: Night -> \(enabled ? "ON" : "OFF")")
	}

	var description: String {
		"Modes(away:\(awayMode), night:\(nightMode))"
	}
}

final class MotionSensorBad {
	let id: String
	// Acoplamiento directo: conoce luces, alarma y modos
	private let lights: [LightBad]
	private let alarm: AlarmBad
	private let modes: ModeCenterBad

	init(id: String, lights: [LightBad], alarm: AlarmBad, modes: ModeCenterBad) {
		self.id = id
		self.lights = lights
		self.alarm = alarm
		self.modes = modes
	}

	func detectMotion() {
		print("👣 Motion at \(id)")
		if modes.awayMode {
			alarm.alert("motion at \(id)")
		} else if modes.nightMode {
			for l in lights { l.setOn(true) }
		} else {
			print("  (sin acción)")
		}
	}
}

final class DoorSensorBad {
	let id: String
	private let entryLight: LightBad?
	private let alarm: AlarmBad
	private let modes: ModeCenterBad

	init(id: String, entryLight: LightBad?, alarm: AlarmBad, modes: ModeCenterBad) {
		self.id = id
		self.entryLight = entryLight
		self.alarm = alarm
		self.modes = modes
	}

	func open() {
		print("🚪 Door[\(id)] OPEN")
		if modes.awayMode {
			alarm.alert("door \(id) opened")
		} else if modes.nightMode {
			entryLight?.setOn(true)
		}
	}

	func close() {
		print("🚪 Door[\(id)] CLOSE")
	}
}

// “Home” con wiring acoplado (no es un Mediator real)
final class SmartHomeBad {
	let livingLight = LightBad(id: "living")
	let entryLight  = LightBad(id: "entry")
	let alarm = AlarmBad()
	let thermostat = ThermostatBad(target: 22)

	lazy var modes = ModeCenterBad(alarm: alarm, thermostat: thermostat, lights: [livingLight, entryLight])
	lazy var motionLiving = MotionSensorBad(id: "living", lights: [livingLight], alarm: alarm, modes: modes)
	lazy var doorFront = DoorSensorBad(id: "front", entryLight: entryLight, alarm: alarm, modes: modes)

	func dump() {
		print("""
		— Home State —
		\(livingLight.description)
		\(entryLight.description)
		\(alarm.description)
		\(thermostat.description)
		\(modes.description)
		""")
	}
}

// MARK: - TODO (tu trabajo)
// 1) Crea un protocolo Mediator, p.ej.:
//
//    enum HomeEvent {
//        case setAway(Bool), setNight(Bool)
//        case motion(room: String)
//        case doorOpened(id: String), doorClosed(id: String)
//        case setTargetTemp(Int)
//    }
//
//    protocol SmartHomeMediator {
//        func notify(sender: AnyObject, event: HomeEvent)
//    }
//
// 2) Haz que Light/Thermostat/Alarm/MotionSensor/DoorSensor no conozcan a otros
//    dispositivos ni a ModeCenter; en su lugar, notifiquen al Mediator. Expón
//    una interfaz mínima para que el Mediator pueda encender/apagar/armar/etc.
// 3) Implementa HomeHubMediator con la lógica actual:
//    - setAway(true) -> arma alarma, eco ON, apaga luces; setAway(false) -> desarma, eco OFF.
//    - motion en night && !away -> enciende luces de esa zona.
//    - motion o doorOpened con away -> dispara alarma.
//    - doorOpened con night -> enciende luz de entrada.
// 4) Mantén el mismo output del Playground.
// 5) Opcional: añade escenas (arrival/bedtime), auto‑apagado, grupos de habitaciones.

// MARK: - Demo (debe seguir funcionando tras el refactor)

#Playground {
	let home = SmartHomeBad()

	print("Escenario 1: Noche activada; movimiento en salón")
	home.modes.setNight(true)
	home.motionLiving.detectMotion()
	home.dump()

	print("\nEscenario 2: Away activado; movimiento en salón -> alarma")
	home.modes.setAway(true)
	home.motionLiving.detectMotion()
	home.dump()

	print("\nEscenario 3: Puerta principal se abre en Away -> alarma")
	home.doorFront.open()
	home.dump()

	print("\nEscenario 4: Away desactivado; se abre puerta en Night -> luz de entrada ON")
	home.modes.setAway(false)
	home.doorFront.open()
	home.dump()
}
