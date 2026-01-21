//
//  PokemonResponseMapper.swift
//  DesignPatternsShowCase
//

import Foundation

struct PokemonResponseMapper {
	static func map(from remote: RemotePokemon) -> PokemonDomain {
		PokemonDomain(name: remote.name, url: remote.url)
	}
}
