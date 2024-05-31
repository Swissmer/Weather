import Foundation
import UIKit
import CoreLocation

struct Service {
    func requestWeatherForLocation(coordinates: CLLocation) async throws -> Weather {
        let long = coordinates.coordinate.longitude
        let lat = coordinates.coordinate.latitude
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(Int(lat))&lon=\(Int(long))&appid=14e1e2d3c3d14d6356cb5f7bbd2c88b1")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let welcome = try JSONDecoder().decode(Weather.self, from: data)
        
        return welcome
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let _: Void = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Image load error")
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }.resume()
    }
}

