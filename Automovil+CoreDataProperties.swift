//
//  Automovil+CoreDataProperties.swift
//  automoviles
//
//  Created by Ezequiel Parada Beltran on 18/07/2020.
//
//

import Foundation
import CoreData


extension Automovil {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Automovil> {
        return NSFetchRequest<Automovil>(entityName: "Automovil")
    }

    @NSManaged public var nombre: String?
    @NSManaged public var busqueda: String?
    @NSManaged public var calificacion: Double
    @NSManaged public var datosImagen: Data?
    @NSManaged public var ultimaPrueba: Date?
    @NSManaged public var vecesProbado: Int32

}
