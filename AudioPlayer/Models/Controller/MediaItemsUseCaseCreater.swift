//
//  MediaQueryConfigure.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/02/05.
//  Copyright © 2019 teranyan. All rights reserved.
//

import Foundation
import MediaPlayer

class MediaItemsUseCaseCreator {
    static func createUseCase(group: MPMediaGrouping) -> UseCaseProtocol? {
        guard MediaItemRepositoryCreator.create(group: group) != nil else {
            return nil
        }
        return MediaItemUseCase(repository: MediaItemRepositoryCreator.create(group: group)!)
    }
}
