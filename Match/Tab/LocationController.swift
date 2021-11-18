//
//  LocationController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/10/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Contacts

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class LocationController: UIViewController {

    let locationManager = CLLocationManager()
    @IBOutlet weak var map: MKMapView!
    var resultSearchController:UISearchController? = nil
    var selectedPin :MKPlacemark?
    @IBOutlet weak var userLoc: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationTableController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
                
        locationSearchTable.mapView = map
        
        locationSearchTable.handleMapSearchDelegate = self
        
        self.tabBarController?.tabBar.isTranslucent = true
        
        userLoc.layer.cornerRadius = userLoc.frame.height/2
        
    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
            let center = map.centerCoordinate;
            map.centerCoordinate = center;
        }
    }
    
    @objc func setHome(){
        FieldPopupController.groundName = ""
        FieldPopupController.map = self
        performSegue(withIdentifier: "namePrompt", sender: self)
        let center = map.centerCoordinate;
        map.centerCoordinate = center;
    }
    
    @objc func book(){
        
        let circularRegion = CLCircularRegion(center:selectedPin!.coordinate, radius: 0.1, identifier: "radius")

        if let userLoc = locationManager.location{
            if circularRegion.contains(userLoc.coordinate){
                //allow player to book
                print("book now")
                self.performSegue(withIdentifier: "book", sender: self)
            }
            else {
                self.presentAlertViewController(title: "You are not close enough to book this ground", message: "Move closer or book another", completion: {})
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BookingController{
            dest.pin = selectedPin
        }
    }

    
    @IBAction func showUserLocation(_ sender: Any) {
        locationManager.requestLocation()
    }
}

extension LocationController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            map.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

extension LocationController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        map.removeAnnotations(map.annotations)
        
        DispatchQueue.main.async {
            if (!AuthenticationController.user.isPlayer) {
                let reuseId = "userLocation"
                var pinView = self.map.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
                let teamAnnotation = MKPointAnnotation()
                teamAnnotation.coordinate = placemark.coordinate
                teamAnnotation.title = "Claim as home ground"
                teamAnnotation.subtitle = ""
                self.map.addAnnotation(teamAnnotation)
            }
            self.addPins(center: placemark.coordinate)
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        
        
        map.setRegion(region, animated: true)
    }
    
    func addPins(center: CLLocationCoordinate2D) {
        let longitude = center.longitude
        let latitude = center.latitude

        #warning("can only do range query on one field at a time, need better workaround")
        #warning("convert screen mapview region span to lat/long")
        
        
        let query = db.collection("grounds")
            .whereField("longitude", isGreaterThanOrEqualTo: longitude-map.region.span.longitudeDelta/2)
            .whereField("longitude", isLessThanOrEqualTo: longitude+map.region.span.longitudeDelta/2)
        query.getDocuments { (querySnapshot, err) in

            for document in querySnapshot!.documents {
                let annotation = MKPointAnnotation()
                let lat = document.data()["latitude"] as! CLLocationDegrees
                if lat <= latitude+self.map.region.span.latitudeDelta/2 && lat >= latitude-self.map.region.span.latitudeDelta/2{
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: document.data()["longitude"] as! CLLocationDegrees)
                    annotation.title = document.data()["title"] as? String
                    annotation.subtitle = document.data()["team"] as? String
                    if annotation.coordinate.latitude != center.latitude && center.longitude != annotation.coordinate.longitude {
                    self.map.addAnnotation(annotation)
                    }
                }
            }
        }
    }
}

extension LocationController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if AuthenticationController.user.isPlayer == true && annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        } else if AuthenticationController.user.isPlayer == false && (annotation is MKUserLocation || annotation.title == "Claim as home ground"){
            if annotation is MKUserLocation && map.centerCoordinate.latitude != annotation.coordinate.latitude && map.centerCoordinate.longitude != annotation.coordinate.longitude {
                return nil
            }
            let reuseId = "userLocation"
            var pinView = map.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            let teamAnnotation = MKPointAnnotation()
            teamAnnotation.coordinate = annotation.coordinate
            teamAnnotation.title = "Claim as home ground"
            teamAnnotation.subtitle = ""
            pinView = MKPinAnnotationView(annotation: teamAnnotation, reuseIdentifier: reuseId)
            pinView?.pinTintColor = UIColor.systemGreen
            pinView?.canShowCallout = true
            let smallSquare = CGSize(width: 30, height: 30)
            let lbutton = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            lbutton.addTarget(self, action: #selector(setHome), for: .touchUpInside)
            lbutton.setImage(UIImage(systemName: "house.fill"), for: .normal)
            pinView?.leftCalloutAccessoryView = lbutton
            /*let rbutton = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            rbutton.addTarget(self, action: #selector(book), for: .touchUpInside)
            rbutton.setImage(UIImage(named: "bat.png"), for: .normal)
            pinView?.rightCalloutAccessoryView = rbutton*/
            return pinView
        }
        let reuseId = "pin"
        var pinView = map.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        let isBooked = false
        #warning("check booked")
        isBooked ? (pinView?.pinTintColor = UIColor.orange) : (pinView?.pinTintColor = UIColor.systemGreen)
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let lbutton = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        lbutton.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        lbutton.setImage(UIImage(systemName: "car"), for: .normal)
        pinView?.leftCalloutAccessoryView = lbutton
        let rbutton = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        rbutton.addTarget(self, action: #selector(book), for: .touchUpInside)
        rbutton.setImage(UIImage(named: "bat.png"), for: .normal)
        pinView?.rightCalloutAccessoryView = rbutton
        return pinView
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        addPins(center: map.centerCoordinate)
        map.removeAnnotations(map.annotations.filter {$0.title == "Claim as home ground" || $0 is MKUserLocation})
        if (!AuthenticationController.user.isPlayer) {
            let reuseId = "userLocation"
            var pinView = self.map.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            let teamAnnotation = MKPointAnnotation()
            teamAnnotation.coordinate = map.centerCoordinate
            teamAnnotation.title = "Claim as home ground"
            teamAnnotation.subtitle = ""
            self.map.addAnnotation(teamAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedPin = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: [CNPostalAddressStreetKey: "\((view.annotation?.title!)!)"])
    }
}
