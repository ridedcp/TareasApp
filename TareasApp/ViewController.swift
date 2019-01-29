//
//  ViewController.swift
//  TareasApp
//
//  Created by Daniel Cano on 01/10/2018.
//  Copyright © 2018 Daniel Cano. All rights reserved.
//

import UIKit
import CoreData
import MGSwipeTableCell

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    
    //ARRAY DE DATOS
//    var searchResults: Array<String> = ["uno", "dos"] //VA A CONTENER LA BUSQUEDA QUE HAGAMOS EN NUESTROS DATOS DE CORE DATA Y ES LO QUE SE VA A MOSTRAR EN LA TABLA, NUESTRAS TAREAS PENDIENTES
    
    //ELEMENTOS DE COREDATA
    
    //me da un objeto de mi entidad, para darme la posibilidad de buscar en mi modelo de datos de CoreData
    let fetchRequest: NSFetchRequest<Tarea> = Tarea.fetchRequest()
    
    //Array de datos vacío
    var searchResults: Array<Tarea> = []
    
    //NSManagedObjectContext es una memoria temporal en la que se guarda antes de guardarse en mi base de datos de Coredata
    var managedObjectContext: NSManagedObjectContext?
    
    
    //Declaro una funcion que me devuelva un objeto de persistent container, es decir, un almacenamiento persistente para poder guardar mis fechas, notas, etc.
    func getContext() -> NSManagedObjectContext {
        
        let myDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate //singleton para usar funciones del appdelegate
        
        return myDelegate.persistentContainer.viewContext
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //añado al managedObjectContext todo lo que haya en el almacen temporal dentro de mi constante
        self.managedObjectContext = getContext()
    }
    
    
    
    
    //Funcion que se ejecuta cuando la vista ya se ha cargado
    override func viewDidAppear(_ animated: Bool) {
        
        self.refrescarDatos()
    }
    
    
    
    //Esta función actualiza mi tabla con los datos guardado en CoreData
    func refrescarDatos(){
        
        
        //Filtro para mostrar las tareas que en el campo tareas completadas no tenga el String "Si"
        let filter = "NO"
        
        //Me da la opcion de poner un filtro (un predicado)
        let predicate = NSPredicate(format: "tareaCompletada = %@", filter) //%@ es lo mismo que no. Por tanto creo un filtro que le digo que es igual a NO
        
        //Lo uso con la clase fetchRequest. Asigno este filtro al fetchRequest
        fetchRequest.predicate = predicate
        
        
        
        
        //Pasar mis datos de coreData a mi array para mostrarlos en la tabla. Para ello uso do/try/catch
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
        }
        catch let error as NSError
        {
            print("El error es: \(error)")
        }
        
        //refresco los datos de la tabla
        self.myTableView.reloadData()
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults.count
    }
    
    
    //METODO QUE DEVUELVE LA CELDA
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Creo una instancia de la clase que he importado al proyecto
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MGSwipeTableCell
        
//        if cell == nil
//        {
//            cell = MGSwipeTableCell(style: .subtitle, reuseIdentifier: "Cell")
//        }
        
        //Pinto los diferentes elementos de mi array de tipo Tarea en la celda, siempre y cuando tenga datos
        if searchResults.count > 0
        {
            //propiedades de mi objeto Tarea
            let tarea: String? = searchResults[indexPath.row].tarea
            let fecha: String? = searchResults[indexPath.row].fecha
            
            //Lo pinto en la celda
            cell.textLabel?.text = "\(tarea!)"
            cell.detailTextLabel?.text = "La fecha límite es: \(fecha!)"
        }
        
        
        //Crear el gesto para marcar tareas como completadas
        cell.leftButtons = [MGSwipeButton(title: "COMPLETADA", backgroundColor: UIColor.blue, callback: { (cell) -> Bool in
            
            //Creo un objeto de la clase NSManagedObject y le paso el objeto de la fila seleccionada
            let selectedIten: NSManagedObject = self.searchResults[indexPath.row] as NSManagedObject
            
            //Guardo en el campo tareaCompletada el string "Si"
            selectedIten.setValue("Si", forKey: "tareaCompletada") //estoy dando por completada mi tarea
            
            let myDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate //Creo objeto de la clase appDelegate para guardar el objeto  con el "Si" en tareaCompletada
            
            //Guardo el objeto de CoreData
            myDelegate.saveContext()
            
            self.refrescarDatos()
            
            return true
            
        }) ]
        
        
        
        return cell
    }
    
    
    //Funcion para gestionar las transiciones en un cambio de vista, con esto accederé a la vistadetalle desde dos sitios diferentes, uno cuando pulse el boton + y otro desde los valores de la celda
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Gestiono la transicion. Defino un condicinal para saber si el origen es una de las celdas con contenido o el boton +
        
        if segue.identifier == "actualizarTarea"
        {
            //VAriable para saber que posicion ha pulsado el usuario
            var indexPath: IndexPath = self.myTableView.indexPathForSelectedRow!
            
            //Creo un objeto de la clase NSManagedObject para gestionar objetos almacenados en core data
            let selectedItem: NSManagedObject = searchResults[indexPath.row] as NSManagedObject //Almacena el objeto seleccionado cuando el usuario hace click en una celda, es decir, almacena el indice
            
            //Creo una instancia de la vista detalle
            let vistaDetalle: ViewControllerTareas = segue.destination as! ViewControllerTareas
            
            //Voy a pasarle los datos de la celdda pulsada a la vistaDetalle
            vistaDetalle.existeTarea = selectedItem
            
        }
    }
    
    
    
    //Metodo delegado de las vistas de tabla para editar las celdas haciendo un gesto que es desplazar el dedo de derecha a izquierda y aparece un boton de borrar
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        do
        {
            if editingStyle == UITableViewCell.EditingStyle.delete
            {
                
                //Acceso seguro a una propiedad. Si es mi tabla...
                if let tableV = self.myTableView
                {
                    
                    //Le digo que gestione todo el borrado de la tarea
                    
                    //Borro dentro de mi array, el indice
                    managedObjectContext?.delete(searchResults[indexPath.row] as NSManagedObject)
                    
                    //Borro el registro de mi array
                    searchResults.remove(at: indexPath.row)
                
                
                    //Estilo de como se borra mi celda
                    tableV.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                }
                
                do
                {
                    //Ahora vuelvo a guardar los datos
                    try managedObjectContext?.save()
                }
                catch let error as NSError
                {
                    print("El error es: \(error)")
                    
                    abort() //funcion para que no siga con lo que estaba haciendo y no pete la app
                }           
            }
        }
    }
}

