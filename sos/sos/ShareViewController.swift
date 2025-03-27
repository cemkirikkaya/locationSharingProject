//
//  ShareViewController.swift
//  sos
//
//  Created by Cem Kırıkkaya on 23.12.2024.
//

import UIKit
import FirebaseFirestore
import MapKit
import CoreLocation
import CoreData
import AVFoundation

class ShareViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var enlem = Double()
    var boylam = Double()
    
    var choosenEnlem = Double()
    var choosenBoylam = Double()
    
    var Elocation = Double()
    var BLocation = Double()
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    // Core Data Stack
    var persistentContainer: NSPersistentContainer! {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupAudioRecorder() // Voice message
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if choosenEnlem != 0 && choosenBoylam != 0 {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Konum")
            fetchRequest.predicate = NSPredicate(format: "enlem == %@ && boylam == %@", enlem, boylam)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try! context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        choosenEnlem = result.value(forKey: "enlem") as! Double
                        choosenBoylam = result.value(forKey: "boylam") as! Double
                    }
                    let annotation = MKPointAnnotation()
                    let coordinate = CLLocationCoordinate2D(latitude: enlem, longitude: boylam)
                    annotation.coordinate = coordinate
                    mapView.addAnnotation(annotation)
                    locationManager.stopUpdatingLocation()
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: coordinate, span: span)
                    mapView.setRegion(region, animated: true)
                }
            }
            /*
             catch {
                 print("Error")
             }
             */
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let requestLocation = CLLocation(latitude: Elocation, longitude: BLocation)
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
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            enlem = coordinate.latitude
            boylam = coordinate.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Konum"
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = (CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude))
        let span = MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let sosLoc = NSEntityDescription.insertNewObject(forEntityName: "Konum", into: context)
        sosLoc.setValue(enlem, forKey: "enlem")
        sosLoc.setValue(boylam, forKey: "boylam")
        
        let geoPoint = GeoPoint(latitude: enlem, longitude: boylam)
        db.collection("locations").addDocument(data: ["geoPoint": geoPoint, "timestamp": FieldValue.serverTimestamp()]) { error in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else {
                print("Konum başarıyla kaydedildi.")
            }
            
            do
            {
                try context.save()
                print("Basarili")
            } catch {
                print("Hata")
            }
        }
    }
    
    @IBAction func stopVoice(_ sender: Any) {
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            saveAudioToCoreData()
        }
    }
    
    // Ses kaydını başlatmak için metot
    func setupAudioRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("message.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
        } catch {
            print("Failed to setup recorder.")
        }
    }
    
    // Core Data'ya kaydetme
    func saveAudioToCoreData() {
        guard let audioURL = audioRecorder?.url else {
            print ("Core Dataya kayıt edilecek dosya yolu bulunamadı")
            return
        }
        do {
            let audioData = try Data(contentsOf: audioURL)
            let context = persistentContainer.viewContext
            let audioMessage = AudioMessage(context: context)
            audioMessage.id = UUID()
            audioMessage.audioData = audioData
            
            try context.save()
            print("Core Dataya basariyla kaydedildi")
        } catch {
            print("Error saving audio to Core Data: \(error)")
        }
    }
    
    // Dosya yolu
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

