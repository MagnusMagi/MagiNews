//
//  Item.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
