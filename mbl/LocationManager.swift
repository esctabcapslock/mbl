import Foundation
import CoreLocation
import Combine

//
//import CoreMotion
//class MagnetometerManager: ObservableObject {
//    private var motionManager = CMMotionManager()
//    @Published var magneticHeading: Double = 0.0
//    @Published var x: Double = 0.0
//    @Published var y: Double = 0.0
//    @Published var z: Double = 0.0
//
//    init() {
//        startMagnetometerUpdates()
//    }
//
//    private func startMagnetometerUpdates() {
//        guard motionManager.isMagnetometerAvailable else { return }
//
//        motionManager.magnetometerUpdateInterval = 1.0 / 10.0 // Update 10 times per second
//        motionManager.startMagnetometerUpdates(to: OperationQueue.current!) { [weak self] data, error in
//            guard let data = data, error == nil else { return }
//            
//            self?.x = data.magneticField.x
//            self?.y = data.magneticField.y
//            self?.z = data.magneticField.z
//            
//            let heading = atan2(data.magneticField.y, data.magneticField.x) * 180 / .pi
//            self?.magneticHeading = heading < 0 ? heading + 360 : heading
//        }
//    }
//
//    deinit {
//        motionManager.stopMagnetometerUpdates()
//    }
//}
//
class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil
    @Published var heading: CLHeading?


    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }

    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error updating location: \(error.localizedDescription)")
    }
}

// 방위각 알아내는용도
extension CLLocation {
    func bearing(to destination: CLLocation) -> Double {
        let lat1 = self.coordinate.latitude * .pi / 180
        let lon1 = self.coordinate.longitude * .pi / 180
        let lat2 = destination.coordinate.latitude * .pi / 180
        let lon2 = destination.coordinate.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var bearing = atan2(y, x) * 180 / .pi // 변환: 라디안 → 도
        bearing = fmod((bearing + 360), 360) // 0-360도 범위로 변환
        
        return bearing
    }
}


func distanceText(for distance: Double) -> String {
        if distance >= 1000 {
            let kilometers = distance / 1000
            return "\(String(format: "%.2f", kilometers)) km"
        } else {
            return "\(String(format: "%.2f", distance)) m"
        }
    }
