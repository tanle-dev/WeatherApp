//
//  ViewController.swift
//  Lab03
//
//  Created by Tan Le on 2024-03-10.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displaySampleIcon()
    }
    
    private func displaySampleIcon(){
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .systemGray5, .systemBlue, .systemFill
        ])
        weatherConditionImage.preferredSymbolConfiguration = config
        
        weatherConditionImage.image = UIImage(systemName: "cloud.rain")
    }

    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
        print("Tan Le")
    }
    
    @IBAction func onLocationTapped(_ sender: UIButton) {
        
    }
    
    private func loadWeather(search: String?){
        guard let search = search else{
            print("No search")
            return
        }
        
//        Step 1: Get url
        guard let url = getURL(query: search) else{
            print("Could not get URL")
            return
        }
        
//        Step 2: Create URLSession
        let session = URLSession.shared
        
//        Step 3: Create task for session
        let dataTask = session.dataTask(with: url){data, response, error in
            // network call finished
            print("Network call complete")
            
            guard error == nil else{
                print("Received error")
                return
            }
            
            guard let data = data else{
                print("Data not found")
                return
            }
            
            // decode the data
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    self.temperatureLabel.text = "\(weatherResponse.current.temp_c) C"
                    self.locationLabel.text = weatherResponse.location.name
                    self.conditionLabel.text = weatherResponse.current.condition.text
                }
            }
            
            
            
        }
        
//        Step 4: Start task
        dataTask.resume()
    }
    
    private func getURL(query: String) -> URL? {
        
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "55c48f2517644151b99160751241203"
        
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        }catch{
            print("Error decoding")
        }
        
        return weather
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location: Decodable{
    let name: String
}

struct Weather: Decodable{
    let temp_c: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable{
    let text: String
    let code: Int
}

