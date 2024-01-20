//
//  NewsManagerTableViewCell.swift
//  Preet_Pambhar_FE_8942790
//
//  Created by user238091 on 12/4/23.
//

import UIKit

class NewsManagerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
        
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var sourceLabel: UILabel!
    
    func configure(with news: Any) {
            if let article = news as? YourProjectNameArticle {
                titleLabel.text = "Title: \(article.title)"
                descriptionLabel.text = "Description: \(article.description)"
                authorLabel.text = "Author Name: \(article.author ?? "Unknown Author")"
                sourceLabel.text = "Source: \(article.source.name)"
                
            } else if let customArticle = news as? YourProjectNameCustomNewsArticle {
                titleLabel.text = "Custom Title: \(customArticle.customTitle)"
                descriptionLabel.text = "Custom Description: \(customArticle.customDescription)"
                authorLabel.text = "Custom Author Name: \(customArticle.customAuthor ?? "Unknown Author")"
                sourceLabel.text = "Custom Source: \(customArticle.customSource)"
            } else {
                titleLabel.text = ""
                descriptionLabel.text = ""
                authorLabel.text = ""
                sourceLabel.text = ""
            }
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
