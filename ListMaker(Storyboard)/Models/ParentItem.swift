//
//  ParentItem.swift
//  ListMaker(Storyboard)
//
//  Created by user on 6/24/22.
//

import Foundation
import RealmSwift

class ParentItem: Object {
    @objc dynamic var name: String = ""
    let childItems = List<ChildItem>()
}
