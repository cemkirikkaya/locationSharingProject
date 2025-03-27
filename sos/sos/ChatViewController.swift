//
//  ChatViewController.swift
//  sos
//
//  Created by Cem Kırıkkaya on 20.12.2024.
//

import UIKit
import FirebaseFirestore
import MapKit
import CoreLocation
import CoreData
import AVFoundation

class ChatViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var latitude = Double()
    var longitude = Double()
    
    let db = Firestore.firestore()
    var konumlar = [GeoPoint] ()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        fetchAndDisplayLocations()
    }
        func fetchAndDisplayLocations() {
            db.collection("locations").getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Veri alınırken hata oluştu: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("Koleksiyon boş.")
                    return
                }
                
                self.konumlar.removeAll()
                
                for document in documents {
                    if let geoPoint = document.data()["geoPoint"] as? GeoPoint {
                        self.konumlar.append(geoPoint)
                    }
                }
                
                self.displayAnnotations()
            }
        }
    
    func displayAnnotations() {
        for geoPoint in self.konumlar {
            let latitude = geoPoint.latitude
            let longitude = geoPoint.longitude
            addAnnotationToMap(latitude: latitude, longitude: longitude)
        }
    }
        
    func addAnnotationToMap(latitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Konum"
        annotation.subtitle = "Enlem: \(latitude), Boylam: \(longitude)"
        
        mapView.addAnnotation(annotation)
        print(latitude)
    }
    //pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .systemBlue
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let requestLocation = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
            if let placemark = placemarks {
                if placemark.count > 0 {
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
    }
}

