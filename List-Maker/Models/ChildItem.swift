//
//  ChildItem.swift
//  ListMaker(Storyboard)
//
//  Created by user on 6/24/22.
//

import Foundation
import RealmSwift

class ChildItem: Object {
    @objc dynamic var name: String = ""
    var parentItem = LinkingObjects(fromType: ParentItem.self, property: "childItems")
}
