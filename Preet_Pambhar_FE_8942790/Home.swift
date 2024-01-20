//
//  Home.swift
//  Preet_Pambhar_FE_8942790
//
//  Created by user238091 on 12/2/23.
//

import UIKit
import CoreLocation
import MapKit

class Home: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    //Define data set
    var location: [UserLocation]?
    //reference object to manage conten
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    
    @IBOutlet weak var myLocation: MKMapView!
    
    
    // set manager object to the CLLocationmanager -Delegate
        let manager = CLLocationManager()
    
    // locatioManager captures current location and calls render function to display loacation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        render(location)
    }

    
    // render then updates based on all the captured details.
        func render (_ location: CLLocation) {
            let coordinate = CLLocationCoordinate2D (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude )
            //span settings determine how much to zoom into the map - defined details
            let span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            let pin = MKPointAnnotation ()
            
            pin.coordinate = coordinate
            myLocation.addAnnotation(pin)
            myLocation.setRegion(region, animated: true)
            
        }
    
    @IBAction func discoverTheWorld(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Where would you like to go", message: "Enter Your destination", preferredStyle: .alert)
        
        //add three option news,location,weather
        // add text field for City Name
        alert.addTextField { (textField) in
            textField.placeholder = "City Name"
        }
        
        // add action for "News" option
        let newsAction = UIAlertAction(title: "News", style: .default) { (action) in
            // handle the "News" option
            if let cityName = alert.textFields?.first?.text {
                print("News for \(cityName)")
                // Add your logic for News option here
                self.saveLocation(cityName: cityName)
            }
        }
        
        // add action for "Location" option
        let locationAction = UIAlertAction(title: "Location", style: .default) { (action) in
            // handle the "Location" option
            if let cityName = alert.textFields?.first?.text {
                print("Location for \(cityName)")
                // Add your logic for Location option here
            }
        }
        
        // add action for "Weather" option
        let weatherAction = UIAlertAction(title: "Weather", style: .default) { (action) in
            // handle the "Weather" option
            if let cityName = alert.textFields?.first?.text {
                print("Weather for \(cityName)")
                // Add your logic for Weather option here
            }
        }
        
        // add the actions to the alert
        alert.addAction(newsAction)
        alert.addAction(locationAction)
        alert.addAction(weatherAction)
        
        // present the alert
        present(alert, animated: true, completion: nil)
    }
    // Function to save the location to Core Data
    func saveLocation(cityName: String) {
        let newUserLocation = UserLocation(context: self.content)
        newUserLocation.location = cityName
        
        // Save the context
        do {
            try self.content.save()
            print("Location saved successfully.")
        } catch {
            print("Error saving location: \(error.localizedDescription)")
        }
    }
}
