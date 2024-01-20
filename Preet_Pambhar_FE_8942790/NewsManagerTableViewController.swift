//
//  NewsManagerTableViewController.swift
//  Preet_Pambhar_FE_8942790
//
//  Created by user238091 on 12/6/23.
//

import UIKit
import Foundation

struct YourProjectNameArticle: Decodable {
    let title: String
    let description: String
    let author: String?
    let source: YourProjectNameSource


    enum CodingKeys: String, CodingKey {
        case title
        case description
        case author
        case source
    }
}

struct YourProjectNameSource: Decodable {
    let name: String
}

struct YourProjectNameResponse: Decodable {
    let articles: [YourProjectNameArticle]


    enum CodingKeys: String, CodingKey {
        case articles
    }
}

struct YourProjectNameCustomNewsArticle {
    let customTitle: String
    let customDescription: String
    let customAuthor: String?
    let customSource: String
    // Add more properties as needed
}

class NewsManagerTableViewController: UITableViewController {

    var selectedCity: String?
    var newsArticles: [YourProjectNameArticle] = []
    var customNewsArticles: [YourProjectNameCustomNewsArticle] = []
    var family: [UserLocation]?
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the table view cell
       // tableView.register(NewsManagerTableViewCell.self, forCellReuseIdentifier: "NewsCell")


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.delegate = self
        tableView.dataSource = self
        //get item from core data
        fetchCity()
        if let city = selectedCity {
            print("Selected city: \(city)")
            getNewsForCity(cityName: city)
        } else {
            print("selectedCity is nil")
        }
    }
    
    @IBAction func addCity(_ sender: Any) {
        // Display an alert to get the new city name from the user
               let alert = UIAlertController(title: "Add City", message: "Enter the name of the city", preferredStyle: .alert)

               alert.addTextField { textField in
                   textField.placeholder = "City Name"
               }

               let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                   if let cityName = alert.textFields?.first?.text {
                       self?.addNewCity(cityName: cityName)
                   }
               }

               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

               alert.addAction(addAction)
               alert.addAction(cancelAction)

               present(alert, animated: true, completion: nil)
        
    }
    
    func addNewCity(cityName: String) {
        // Create a new UserLocation entity and save it to Core Data
        let newCity = UserLocation(context: content)
        newCity.location = cityName

        do {
            try content.save()
            selectedCity = cityName
            print("New city added: \(cityName)")
            getNewsForCity(cityName: cityName)
        } catch {
            print("Error saving new city: \(error)")
        }
    }

   
    
    func fetchCity() {
        // Check for data and queue into local memory
        do {
            let fetchedCities = try content.fetch(UserLocation.fetchRequest()) as! [UserLocation]

            if let firstCity = fetchedCities.first {
                // Assuming the UserLocation entity has a property named 'location'
                self.selectedCity = firstCity.location
                print("Selected city: \(selectedCity ?? "No city available")")
                getNewsForCity(cityName: selectedCity ?? "")
            } else {
                print("No city data available")
            }

            // Move this part inside the do block
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching city data: \(error)")
        }
    }

    // Function to save news articles to Core Data
    func saveNewsToCoreData(articles: [YourProjectNameArticle]) {
        for article in articles {
            let newUserLocation = UserLocation(context: self.content)
            newUserLocation.location = article.title
            newUserLocation.title = article.title
            newUserLocation.newsDescription = article.description
            newUserLocation.author = article.author
            newUserLocation.source = article.source.name
            // Add more attributes as needed
        }

        do {
            try content.save()
            print("News data saved successfully.")
        } catch {
            print("Error saving news data: \(error.localizedDescription)")
        }
    }
    
    func getNewsForCity(cityName: String) {
        print("Fetching news for city: \(cityName)")
        if let encodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://newsapi.org/v2/everything?q=\(encodedCityName)&apiKey=3ba919227d26437592cc7f71ed2daa96") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching news: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received from the API")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let newsResponse = try decoder.decode(YourProjectNameResponse.self, from: data)

                    print("Decoded Response: \(newsResponse)")

                    // Update newsArticles with the actual API response
                    self.newsArticles = newsResponse.articles

                    // Update customNewsArticles with the new articles
                    self.customNewsArticles = newsResponse.articles.map { article in
                        YourProjectNameCustomNewsArticle(
                            customTitle: article.title,
                            customDescription: article.description,
                            customAuthor: article.author,
                            customSource: article.source.name
                        )
                    }

                    // Update the UI on the main thread
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }.resume()
        } else {
            print("Invalid URL")
        }
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsArticles.count + customNewsArticles.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsManagerTableViewCell

        // Configure the cell...
               if indexPath.row < newsArticles.count {
                   // Standard news cell
                   let article = newsArticles[indexPath.row]
                   cell.configure(with: article)
                   cell.titleLabel.isHidden = false
                   cell.descriptionLabel.isHidden = false
                   cell.authorLabel.isHidden = false
                cell.sourceLabel.isHidden = false
               } else {
                   // Custom news cell
                   let customIndex = indexPath.row - newsArticles.count
                   if customIndex < customNewsArticles.count {
                       let customArticle = customNewsArticles[customIndex]
                       cell.configure(with: customArticle)
                       cell.titleLabel.isHidden = true
                       cell.descriptionLabel.isHidden = true
                       cell.authorLabel.isHidden = true
                       cell.sourceLabel.isHidden = true
                   } else {
                       // Handle the case when the custom index is out of bounds
                       print("Custom index out of bounds")
                   }
               }

        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
