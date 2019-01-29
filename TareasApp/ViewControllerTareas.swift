//
//  ViewControllerTareas.swift
//  TareasApp
//
//  Created by Daniel Cano on 01/10/2018.
//  Copyright © 2018 Daniel Cano. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerTareas: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var txtTarea: UITextField!
    @IBOutlet weak var txtFecha: UITextField!
    @IBOutlet weak var txtNotas: UITextView!
    
    
    //Creo la variable que me permite generar un objeto de la clase DatePicker (un selector de fecha)
    let datePickerView: UIDatePicker = UIDatePicker()
    
    //Objeto de la clase NSMAnagedObject para ver si existe alguna tarea
    var existeTarea: NSManagedObject!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Creo los elementos que me permitiran introducir tareas
        
        //Objeto datePicker, solo muestro la fecha cuando el picker se presente
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        
        //le doy una posicion en pantalla y un tamaño
        datePickerView.frame = CGRect(x: 10, y: 500, width: self.view.frame.width, height: 200)
        
        //defino algunas propiedades de mi datePicker, zona del tiempo y un color de fondo
        datePickerView.timeZone = NSTimeZone.local
        datePickerView.backgroundColor = UIColor.white
        
        //Gestiono cuando el usuario selecciona una fecha, que nuestro objeto se lo comunique a nuestro controlador. Uso el patron target ---> action
        datePickerView.addTarget(self, action: #selector(ViewControllerTareas.datePickerCambioValor), for: UIControl.Event.valueChanged)
        
        
        //Si existePersona tiene algo lo mestre en mis textFields
        if existeTarea != nil
        {
            self.txtTarea.text = existeTarea.value(forKey: "tarea") as! String?
            self.txtFecha.text = existeTarea.value(forKey: "fecha") as! String?
            self.txtNotas.text = existeTarea.value(forKey: "nota") as! String?
        }
    }
    
    
    //Funcion delegada del protocolo UITextFieldDelegate. Detecta cuando el campo de texto comienza a ser editado
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        txtFecha.inputView = datePickerView
    }
    
    
    
    
    //Esta funcion pinta el valor seleccionado por el usuario de nuestro datePicker
    @objc func datePickerCambioValor(sender: UIDatePicker) {
        
        //Creo el formato de fecha
        let dateFormate: DateFormatter = DateFormatter()

        //formato que le quiero pasar, es un estanda: dia, mes año
        dateFormate.dateFormat = "dd/MM/yyyy"
        
        //Aplico el formato
        let selectedDate: String = dateFormate.string(from: sender.date)
        
        //A mi texfield de fecha le paso la fecha
        self.txtFecha.text = selectedDate
    }
    
    

    @IBAction func guardarTarea(_ sender: Any) {
        
        //declaro una constante a mi clase Appdelegate que es donde esta todo lo de coredata
        let myDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //Creo un objeto objectContext que me permite almacenar en mi base de datos de core data valores
        let objectContext = myDelegate.persistentContainer.viewContext
        
        //condicional que comprueba si existe la tarea, si existe la actualiza, si no existe, la crea nueva
        if existeTarea != nil
        {
            //ACTUALIZA LOS DATOS
            //Codificacion KVC (Key Value Coding), es decir, guardar un valor con una clave
            existeTarea.setValue(txtTarea.text, forKey: "tarea") //esta clave es la de la entity
            existeTarea.setValue(txtFecha.text, forKey: "fecha")
            existeTarea.setValue(txtNotas.text, forKey: "nota")
            
        }
        else
        {
            //AÑADIR NUEVA TAREA
            
            //Creo una instancia de la clase Tarea y le asigno la entidad de coredata y un contexto (objectContext)
            
            //Instancia de la entidad de CoreData con sus atributos
            let newTarea = NSEntityDescription.insertNewObject(forEntityName: "Tarea", into: objectContext) as! Tarea
            
            //A la constante le añado los datos que quiero guardar
            newTarea.tarea = txtTarea.text
            newTarea.fecha = txtFecha.text
            newTarea.nota = txtNotas.text
            newTarea.tareaCompletada = "NO"
        }
        
        
        //PERSISTIR TODO: De estar guardado en nuestra memoria temporal a nuestra bbdd de CoreData
        myDelegate.saveContext()
        
        //Una vez se actualice la tarea, vuelva a la pantalla de origen
        _ = navigationController?.popToRootViewController(animated: true)
        
    }
    
    
    
    @IBAction func cancelar(_ sender: Any) {
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    

}
