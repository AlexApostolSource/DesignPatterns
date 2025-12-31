//
//  Kata4LocalDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 3/11/25.
//
import Foundation

protocol Kata4LocalDataSourceProtocol {
	func fetchList(limit: Int, offset: Int) -> [PokemonDomain]?
	func saveList(_ list: [PokemonDomain])
	func saveDetail(nameOrId: String, detail: PokemonDetail)
	func clearCache()
	func getDetail(nameOrId: String) -> PokemonDetail?
	func currentCacheSize() -> Int
}

final class Kata4LocalDataSource: Kata4LocalDataSourceProtocol {
	private let lock = NSRecursiveLock()
	private var _listData: [PokemonDomain] = []
	private var listData: [PokemonDomain] {
		get {
			lock.lock()
			defer { lock.unlock() }
			return _listData
		}
		set {
			lock.lock()
			defer { lock.unlock() }
			_listData = newValue
		}
	}
	private var _listDetail: [String: PokemonDetail] = [:]
	private var listDetail: [String: PokemonDetail] {
		get {
			lock.lock()
			defer { lock.unlock() }
			return _listDetail
		}
		set {
			lock.lock()
			defer { lock.unlock() }
			_listDetail = newValue
		}
	}

	func fetchList(limit: Int, offset: Int) -> [PokemonDomain]? {
		guard offset < listData.count else { return nil }

		let start = offset
		let end = min(offset + limit, listData.count)
		return Array(listData[start..<end])
	}


	func clearCache() {
		listData.removeAll()
		listDetail.removeAll()
	}

	func saveList(_ list: [PokemonDomain]) {
		listData += list
	}

	func saveDetail(nameOrId: String, detail: PokemonDetail) {
		listDetail[nameOrId] = detail
	}

	func getDetail(nameOrId: String) -> PokemonDetail? {
		listDetail[nameOrId]
	}

	func currentCacheSize() -> Int {
		return listDetail.count
	}
}

struct PokemonData {
	let name: String
	let url: String
}
