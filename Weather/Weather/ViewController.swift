import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var coordinates: CLLocation?
    var requestService = Service()
    
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
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func updateCoordinates() {
        coordinates = nil
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, coordinates == nil {
            coordinates = locations.first
            locationManager.stopUpdatingLocation()
            if let coordinates = coordinates {
                Task {
                    do {
                        let result = try await requestService.requestWeatherForLocation(coordinates: coordinates)
                        DispatchQueue.main.async { [weak self] in
                            self?.setValueBoard(value: result)
                        }
                    } catch {
                        print("Failed to fetch weather: \(error)")
                    }
                }
            }
        }
    }
    
    func setValueBoard(value: Welcome) {
        if let icon = value.weather?.first?.icon {
            let urlString = "https://openweathermap.org/img/wn/\(icon).png"
            if let url = URL(string: urlString) {
                requestService.loadImage(from: url) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.icon.image = image
                        self?.city.text = "\(value.name!)"
                        self?.date.text = "Today \(Date().formatted(.dateTime.month().day().hour().minute()))"
                        self?.degrees.text = "\(self!.fromKToC(value.main?.temp)) °C"
                    }
                }
            }
        }
    }
    
    func fromKToC(_ value: Double?) -> String {
        var result: Double = 0
        if let value = value {
            result = value - 273
        }
        return String(format: "%.1f", result)
    }
}
