//
//  DirectionsViewController.swift
//  Preet_Pambhar_FE_8942790
//
//  Created by user238091 on 12/7/23.
//

import CoreLocation
import UIKit
import MapKit

class DirectionsViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    //Define data set
    var location: [UserLocation]?
    //reference object to manage conten
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentRouteOverlay: MKPolyline?
    let geocoder = CLGeocoder()
    var destinationCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        // Enable session sharing
        myLocation.showsUserLocation = true
        myLocation.delegate = self
        zoomSlider.minimumValue = 1.0
        zoomSlider.maximumValue = 20.0
        setupSlider()
    }
    
    @IBOutlet weak var zoomSlider: UISlider!
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        // The slider value represents the zoom level
          let zoomLevel = Double(sender.value)

          // Set a reasonable maximum and minimum zoom level
          let maxZoomLevel: Double = 20.0
          let minZoomLevel: Double = 0.1

          // Calculate the new span based on the zoom level
          let newLatitudeDelta = max(myLocation.region.span.latitudeDelta / zoomLevel, minZoomLevel)
          let newLongitudeDelta = max(myLocation.region.span.longitudeDelta / zoomLevel, minZoomLevel)

          // Ensure the new span is within reasonable bounds
          let clampedLatitudeDelta = min(newLatitudeDelta, maxZoomLevel)
          let clampedLongitudeDelta = min(newLongitudeDelta, maxZoomLevel)

          let newSpan = MKCoordinateSpan(latitudeDelta: clampedLatitudeDelta, longitudeDelta: clampedLongitudeDelta)
          let newRegion = MKCoordinateRegion(center: myLocation.region.center, span: newSpan)

          // Set the new region on the map
          myLocation.setRegion(newRegion, animated: true)
    }
    
    func setupSlider() {
           zoomSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
       }
    
    func zoomIn(zoomLevel: Double) {
        let currentRegion = myLocation.region
        let span = MKCoordinateSpan(
            latitudeDelta: currentRegion.span.latitudeDelta / zoomLevel,
            longitudeDelta: currentRegion.span.longitudeDelta / zoomLevel
        )
        
        let newRegion = MKCoordinateRegion(
            center: currentRegion.center,
            span: span
        )
        
        myLocation.setRegion(newRegion, animated: true)
    }

    func zoomOut(zoomLevel: Double) {
        let currentRegion = myLocation.region
        let span = MKCoordinateSpan(
            latitudeDelta: currentRegion.span.latitudeDelta * zoomLevel,
            longitudeDelta: currentRegion.span.longitudeDelta * zoomLevel
        )
        
        let newRegion = MKCoordinateRegion(
            center: currentRegion.center,
            span: span
        )
        
        myLocation.setRegion(newRegion, animated: true)
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
    
    @IBAction func addLocation(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Where would you like to go", message: "Enter your new destination here", preferredStyle: .alert)
        
        //add three option news,location,weather
        // add text field for City Name
        alert.addTextField { (textField) in
            textField.placeholder = "City Name"
        }
        
        // add action for "Location" option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let locationAction = UIAlertAction(title: "Go", style: .default) { (action) in
            // handle the "Location" option
            if let cityName = alert.textFields?.first?.text {
                print("Location for \(cityName)")
                
                // Call calculateRoute with the destination text
                self.geocodeAndMap(destination: cityName)
            }
        }
        
        // add the actions to the alert
        alert.addAction(cancelAction)
        alert.addAction(locationAction)
      
        
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
    
    func geocodeAndMap(destination: String) {
           geocoder.geocodeAddressString(destination) { [weak self] (placemarks, error) in
               if let error = error {
                   print("Geocoding error: \(error.localizedDescription)")
                   return
               }

               guard let placemark = placemarks?.first, let location = placemark.location else {
                   print("Location not found")
                   return
               }

               self?.destinationCoordinate = location.coordinate
               self?.mapThis(transportType: .automobile)
           }
       }
    
    @IBAction func carRoute(_ sender: UIButton) {
        mapThis(transportType: .automobile)
    }
    
    
    @IBAction func bikeRoute(_ sender: UIButton) {
        mapThis(transportType: .walking)
    }
    
    
    @IBAction func walkingRoute(_ sender: UIButton) {
        mapThis(transportType: .walking)
    }
    
    func mapThis(transportType: MKDirectionsTransportType) {
            guard let destinationCoordinate = destinationCoordinate else {
                print("Destination coordinate not set.")
                return
            }
            // Clear existing overlays and annotations
            myLocation.removeOverlays(myLocation.overlays)
            myLocation.removeAnnotations(myLocation.annotations)


            let sourceCoordinate = manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
            let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

            let sourceItem = MKMapItem(placemark: sourcePlacemark)
            let destinationItem = MKMapItem(placemark: destinationPlacemark)

            let destinationRequest = MKDirections.Request()
            destinationRequest.source = sourceItem
            destinationRequest.destination = destinationItem
            destinationRequest.transportType = transportType

            let directions = MKDirections(request: destinationRequest)
            directions.calculate { [weak self] (response, error) in
                guard let response = response else {
                    if let error = error {
                        print("Something went wrong: \(error.localizedDescription)")
                    }
                    return
                }

                let route = response.routes[0]
                self?.myLocation.addOverlay(route.polyline)
                self?.myLocation.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0), animated: true)

                let pin = MKPointAnnotation()
                pin.coordinate = destinationCoordinate
                pin.title = "END POINT"
                self?.myLocation.addAnnotation(pin)
            }
        }



    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
          if let polyline = overlay as? MKPolyline {
              let renderer = MKPolylineRenderer(polyline: polyline)
              renderer.strokeColor = UIColor.blue
              renderer.lineWidth = 3.0
              return renderer
          }
          return MKOverlayRenderer(overlay: overlay)
      }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
