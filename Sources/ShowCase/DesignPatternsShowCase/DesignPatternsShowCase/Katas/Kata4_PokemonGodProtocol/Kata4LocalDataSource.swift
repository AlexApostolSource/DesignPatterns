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
	func saveDetail(nameOrId: String, detail: Data)
	func clearCache()
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
	private var _listDetail: [String: Data] = [:]
	private var listDetail: [String: Data] {
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
		guard offset < listData.count else {
			return nil
		}
		let index = listData.index(listData.startIndex, offsetBy: offset)
		if index.advanced(by: limit) > listData.count {
			return listData
		}
		return nil
	}

	func fetchDetail(nameOrId: String, completion: @escaping (Data?) -> Void) {
		if let data = listDetail[nameOrId] {
			completion(data)
			return
		}
		completion(nil)
	}

	func clearCache() {
		listData.removeAll()
		listDetail.removeAll()
	}

	func saveList(_ list: [PokemonDomain]) {
		listData += list
	}

	func saveDetail(nameOrId: String, detail: Data) {
		listDetail[nameOrId] = detail
	}

	

}

struct PokemonData {
	let name: String
	let url: String
}
