//
//  Tarea+CoreDataProperties.swift
//  TareasApp
//
//  Created by Dani on 2/10/18.
//  Copyright © 2018 Daniel Cano. All rights reserved.
//
//

import Foundation
import CoreData


extension Tarea {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tarea> {
        return NSFetchRequest<Tarea>(entityName: "Tarea")
    }

    @NSManaged public var tarea: String?
    @NSManaged public var fecha: String?
    @NSManaged public var nota: String?
    @NSManaged public var tareaCompletada: String?

}
