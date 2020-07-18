//
//  ViewController.swift
//  automoviles
//
//  Created by Juan on 19/01/17.
//  Copyright © 2017 Juan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var managedContext: NSManagedObjectContext!
    
    @IBOutlet weak var fotografiaAutomovil: UIImageView!
    
    
    @IBOutlet weak var marcasSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var modeloLabel: UILabel!
    
    @IBOutlet weak var calificacionLabel: UILabel!
    
    @IBOutlet weak var numeroPruebasLabel: UILabel!
    
    @IBOutlet weak var ultimaPruebaLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guardarDatosPlistEnCoreData()
    }
    
    func guardarDatosPlistEnCoreData() {
        let peticion = NSFetchRequest<Automovil>(entityName: "Automovil")
        
        peticion.predicate = NSPredicate(format: "nombre != nil")
        
        let cantidad = try! managedContext.count(for: peticion)
        if cantidad > 0 {
            // la informacion inicial de nuestro plist ya esta en e el core data
            print("Core Data ya tiene la informacion inicial del Plist")
            return
        } else {
            print("Se ingresaran los datos iniciales que estan en ListaDatosIniciales.plist")
            let pathPlist = Bundle.main.path(forResource: "ListaDatosIniciales", ofType: "plist")
            let arregloDatosPlist = NSArray(contentsOfFile: pathPlist!)!
            for diccionarioDatosPlist in arregloDatosPlist {
                let entity = NSEntityDescription.entity(forEntityName: "Automovil", in: managedContext)!
                let automovil = Automovil(entity: entity, insertInto: managedContext)
                let dicAutomovil = diccionarioDatosPlist as! [String:AnyObject]
                
                automovil.nombre = dicAutomovil["nombre"] as? String
                automovil.busqueda = dicAutomovil["busqueda"] as? String
                automovil.calificacion = dicAutomovil["calificacion"] as! Double
                let nombreArchivo = dicAutomovil["nombreImagen"] as? String
                let imagen = UIImage(named: nombreArchivo!)
                
                
                let datosArchivoImg =  imagen?.jpegData(compressionQuality: 0.5)
                automovil.datosImagen = NSData(data: datosArchivoImg!) as Data
                automovil.ultimaPrueba = dicAutomovil["ultimaPrueba"] as? Date
                
                let vecesProbado = dicAutomovil["vecesProbado"] as! NSNumber
                automovil.vecesProbado = vecesProbado.int32Value
                
                
            }
            
            
            try! managedContext.save()
        }
    }

    @IBAction func segmentedControl(_ sender: Any) {
    }
   
    @IBAction func probar(_ sender: Any) {
    }

    @IBAction func calificar(_ sender: Any) {
    }

}

