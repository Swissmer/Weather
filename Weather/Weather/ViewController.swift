import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    private var coordinates: CLLocation?
    private var requestService = Service()
    
    @IBOutlet var city: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var degrees: UILabel!
    @IBOutlet var icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, coordinates == nil {
            coordinates = locations.first
            locationManager.stopUpdatingLocation()
            getCurrentWeather()
        }
    }
    
    private func getCurrentWeather() {
        if let coordinates = coordinates {
            Task {
                do {
                    let weather = try await requestService.requestWeatherForLocation(coordinates: coordinates)
                    setWeatherInBoard(weather: weather)
                } catch {
                    print("Failed to fetch weather: \(error)")
                }
            }
        }
    }
    
    private func setWeatherInBoard(weather: Weather) {
        if let icon = weather.weather?.first?.icon {
            let photoURL = "https://openweathermap.org/img/wn/\(icon).png"
            if let url = URL(string: photoURL) {
                requestService.loadImage(from: url) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.icon.image = image
                        self?.city.text = "\(weather.name!)"
                        self?.date.text = "Today \(Date().formatted(.dateTime.month().day().hour().minute()))"
                        self?.degrees.text = "\(self!.fromKelvinToCelsius(weather.main?.temp)) °C"
                    }
                }
            }
        }
    }
    
    private func fromKelvinToCelsius(_ value: Double?) -> String {
        var result: Double = 0
        if let value = value {
            result = value - 273
        }
        return String(format: "%.1f", result)
    }
    
    @IBAction func updateCoordinates() {
        coordinates = nil
        locationManager.startUpdatingLocation()
    }
    
}
