//
//  ViewController.swift
//  Preet_Pambhar_Lab8_8942790
//
//  Created by user238091 on 11/30/23.
//

import UIKit
import CoreLocation
import Foundation

struct WeatherData: Codable {
    let coord: Coord
    let weather: [WeatherElement]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone, id: Int
    let name: String
    let cod: Int
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity : Int
    let seaLevel, groundLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
    }
}

// MARK: - Sys
struct Sys: Codable {
    let type: Int?
    let country: String
    let sunrise, sunset: Int
}

// MARK: - WeatherElement
struct WeatherElement: Codable {
    let id: Int
    let main, description, icon: String
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
    var speedInKilometersPerHour: Double {
           return speed * 3.6
       }

}


class WeatherService {
    static let shared = WeatherService()

    private let apiKey = "3c86cdb94245fa2ca3d0c97d28abc112"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"

    func getWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
       
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            do {
                let decoder = JSONDecoder()
                let weatherInfo = try decoder.decode(WeatherData.self, from: data!)
                completion(.success(weatherInfo))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
}


class Weather: UIViewController, CLLocationManagerDelegate {

    
    
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var condition: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var windSpeed: UILabel!
    
    
    @IBOutlet weak var feelsLike: UILabel!
    
    @IBOutlet weak var lowTemperature: UILabel!
    
    @IBOutlet weak var highTemperature: UILabel!
   
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //to add new location
    @IBAction func newLocation(_ sender: Any) {
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
                
                // Call the function to handle the new location
                self.handleNewLocation(cityName: cityName)
            }
        }
        
        // add the actions to the alert
        alert.addAction(cancelAction)
        alert.addAction(locationAction)
      
        
        // present the alert
        present(alert, animated: true, completion: nil)
    }
    
    // Function to handle new location input
      func handleNewLocation(cityName: String) {
          let geocoder = CLGeocoder()

          geocoder.geocodeAddressString(cityName) { (placemarks, error) in
              if let error = error {
                  print("Geocoding error: \(error.localizedDescription)")
                  return
              }

              if let location = placemarks?.first?.location {
                  // Use the location coordinates for fetching weather data
                  WeatherService.shared.getWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { result in
                      switch result {
                      case .success(let weatherInfo):
                          // Update UI with new weather data
                          DispatchQueue.main.async {
                              self.updateUI(with: weatherInfo)
                          }

                          // Store weather data in local storage
                          //self.saveWeatherData(weatherInfo, for: cityName)

                      case .failure(let error):
                          print("Error fetching weather data: \(error)")
                      }
                  }
              }
          }
      }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        WeatherService.shared.getWeatherData(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let weatherInfo):
                DispatchQueue.main.async {
                    self.updateUI(with: weatherInfo)
                }
            case .failure(let error):
                print("Error fetching weather data: \(error)")
            }
        }
    }

    func updateUI(with weather: WeatherData) {
        cityName.text = weather.name
        
        //to get weather icon
        let iconName = weather.weather[0].icon
        let iconURL = "https://openweathermap.org/img/w/\(iconName).png"
        if let url = URL(string: iconURL) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                } else if let data = data {
                    DispatchQueue.main.async {
                        self.icon.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        temperature.text = "\(weather.main.temp)°C"
        if let firstWeatherCondition = weather.weather.first
           {
            // Display the weather condition
            self.condition.text = firstWeatherCondition.main
           }
        humidity.text = "Humidity:\(weather.main.humidity)%"
        windSpeed.text = "Wind Speed:\(weather.wind.speedInKilometersPerHour) Km/h"
        feelsLike.text = "\(weather.main.feelsLike)°C"
        lowTemperature.text = "Highest: \(weather.main.tempMin)°C"
        highTemperature.text = "Lowest: \(weather.main.tempMax)°C"
    }


}

