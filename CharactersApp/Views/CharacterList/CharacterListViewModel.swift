//
//  CharacterListViewModel.swift
//  CharacterViewerApp
//
//  Created by William on 6/12/23.
//

import Foundation
import Combine

class CharacterListViewModel {
    
    @Published var characterData: [CharacterModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let network: NetworkManagerType
    
    init(network: NetworkManagerType = NetworkManager()) {
        self.network = network
    }
    
    func fetchData() async {
        do {
            let model: CharacterModelContainer = try await network.getCharacters()
            characterData = model.RelatedTopics
            
        } catch {
            print("Error fetching character data: \(error)")
        }
    }
    
}
