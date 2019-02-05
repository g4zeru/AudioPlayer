//
//  ItemRepository.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/02/03.
//  Copyright © 2019 teranyan. All rights reserved.
//

import Foundation
import MediaPlayer
protocol MediaItemRepository: class {
    var dataStore: ItemDataStore? { get }
    func fetch(complition: @escaping (_ query: MPMediaQuery?)-> Void)
    func fetch(keyword: String,complition: @escaping (_ query: MPMediaQuery?)-> Void)
}
