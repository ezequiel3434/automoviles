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
    
    var automovilActual: Automovil!
    
    @IBOutlet weak var fotografiaAutomovil: UIImageView!
    
    
    @IBOutlet weak var marcasSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var modeloLabel: UILabel!
    
    @IBOutlet weak var calificacionLabel: UILabel!
    
    @IBOutlet weak var numeroPruebasLabel: UILabel!
    
    @IBOutlet weak var ultimaPruebaLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guardarDatosPlistEnCoreData()
        
        let peticion = NSFetchRequest<Automovil>(entityName: "Automovil")
        let primerTitulo = marcasSegmentedControl.titleForSegment(at: 0)!
        peticion.predicate = NSPredicate(format: "busqueda == %@", primerTitulo)
        
        do {
            let resultados = try managedContext.fetch(peticion)
            automovilActual = resultados.first!
            popularDatos(automovil: automovilActual)
            
        } catch let error as NSError{
            print("No pude recuperar datos \(error), \(error.userInfo)")
        }
        
        
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
    
    
    func popularDatos(automovil: Automovil) {
        guard let datosImagen = automovil.datosImagen as? Data,
            let ultimaPrueba = automovil.ultimaPrueba as? Date
            else {
                return
        }
        
        // IBOutlets
        
        fotografiaAutomovil.image = UIImage(data: datosImagen)
        
        let formatoFecha = DateFormatter()
        formatoFecha.dateStyle = .short
        formatoFecha.timeStyle = .none
        
        ultimaPruebaLabel.text = "Ultima prueba: " + formatoFecha.string(from: ultimaPrueba)
        
        modeloLabel.text = automovil.nombre
        calificacionLabel.text = "Calificacion: \(automovil.calificacion)"
        numeroPruebasLabel.text = "Veces probado: \(automovil.vecesProbado)"
    }

    @IBAction func segmentedControl(_ sender: Any) {
        guard let selectorAutomovil = sender as? UISegmentedControl else {
            return
        }
        let automovilSeleccionado = selectorAutomovil.titleForSegment(at: selectorAutomovil.selectedSegmentIndex)
        let peticion = NSFetchRequest<Automovil>(entityName: "Automovil")
        peticion.predicate = NSPredicate(format: "busqueda == %@", automovilSeleccionado!)
        
        do {
            let resultado = try managedContext.fetch(peticion)
            automovilActual = resultado.first!
            
            popularDatos(automovil: automovilActual)
            
            
            
        } catch let error as NSError {
            print("No se pudo recuperar info por : \(error), \(error.userInfo)")
        }
        
        
    }
   
    @IBAction func probar(_ sender: Any) {
        
        
        automovilActual.vecesProbado += 1
        
        automovilActual.ultimaPrueba = NSDate() as Date
        
        do {
            try managedContext.save()
            popularDatos(automovil: automovilActual)
        } catch let error as NSError {
            print("No se pudo guardar datos nuevo: \(error)")
        }
        
    }

    @IBAction func calificar(_ sender: Any) {
        let alerta = UIAlertController(title: "Calificación", message: "Califica el Automovil", preferredStyle: .alert)
        
        alerta.addTextField { (campoTexto) in
            campoTexto.keyboardType = .decimalPad
        }
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        let guardar = UIAlertAction(title: "Save", style: .default) { [unowned self]action in
            guard let campoTexto = alerta.textFields?.first
                else {
                    return
            }
            guard let stringCalificacion = campoTexto.text, let calificacion = Double(stringCalificacion)
                else {
                    return
            }
            self.automovilActual.calificacion = calificacion
            
            do{
                try self.managedContext.save()
                self.popularDatos(automovil: self.automovilActual)
                
            }catch let error as NSError {
                
                 if error.domain == NSCocoaErrorDomain &&
                                   (error.code == NSValidationNumberTooLargeError ||
                                       error.code == NSValidationNumberTooSmallError) {
                                   self.calificar(self.automovilActual)
                               } else {
                                   print("No se pudo guardar \(error), \(error.userInfo)")
                }}
            
        }
        alerta.addAction(cancelar)
        alerta.addAction(guardar)
        present(alerta, animated: true)
        
       
    }

}

