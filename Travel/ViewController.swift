//
//  ViewController.swift
//  Travel
//
//  Created by MAC on 24/02/20.
//  Copyright © 2020 MAC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameText: UITextField!
    
    
    @IBOutlet weak var commentText: UITextField!
    
    var locationManager = CLLocationManager()
    var choosenLongitide = Double()
    var choosenLatitude = Double()
    

    
    var selectedTitle = ""
    var selectedTitleId : UUID?
    var annontationTilte = ""
    var annontationSubtitle = ""
    var annontationLongitude = Double()
    var annontationLatitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
    
        
        if selectedTitle != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleId!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do {
                
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String {
                   annontationTilte = title
                       
                    
                        if let subtitle = result.value(forKey: "subtitle") as? String {
                           annontationSubtitle = subtitle
                        
                        if let longitude = result.value(forKey: "longitude") as? Double {
                            
                            annontationLongitude = longitude
                            
                       
                        if let latitude = result.value(forKey: "latitude") as? Double {
                            annontationLatitude = latitude
                            
                            let annontation = MKPointAnnotation()
                            annontation.title = annontationTilte
                            annontation.subtitle = annontationSubtitle
                            let coordinate = CLLocationCoordinate2D(latitude: annontationLatitude, longitude: annontationLongitude)
                            annontation.coordinate = coordinate
                            mapView.addAnnotation(annontation)
                            nameText.text = annontationTilte
                            commentText.text = annontationSubtitle
                            locationManager.stopUpdatingLocation()
                            
                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            let region = MKCoordinateRegion(center: coordinate, span: span)
                            mapView.setRegion(region, animated: true)
                            
                        }
                            }
                            }
                        }
                    }
                }
            }
                catch {
                
                print("error")
            }
            
            
            
            
            }
            else {
           
            
        }
        
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
     
        if annotation is MKUserLocation {
            return nil
        }
        
        
        let reuseId = "myAnnnontation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)  as? MKPinAnnotationView
       
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            
            
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        
        
        return pinView
        
    }

    
    
    
    
    @objc  func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let touchCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            choosenLatitude = touchCoordinates.latitude
            choosenLongitide = touchCoordinates.longitude
            
            let annontation = MKPointAnnotation()
            annontation.coordinate = touchCoordinates
            annontation.title = nameText.text
            annontation.subtitle = commentText.text
            self.mapView.addAnnotation(annontation)
            
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == ""  {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        } else {
            
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
            
            
            let requestLocation = CLLocation(latitude: annontationLatitude, longitude: annontationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                
                
                if let placemark = placemarks {
                    if placemark.count > 0 {
                let newplacemark = MKPlacemark(placemark: placemark[0])
                                       let item = MKMapItem(placemark: newplacemark)
                        
                        item.name = self.annontationTilte
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                        
                        
                        
                        
                }
                
                
               
                }
            }
        }
    }


    @IBAction func savePressed(_ sender: UIButton) {
   
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(choosenLongitide, forKey: "longitude")
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
    
        
        NotificationCenter.default.post(name: NSNotification.Name("new Place"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
    
}

