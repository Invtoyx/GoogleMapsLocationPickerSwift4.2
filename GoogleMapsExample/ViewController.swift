//
//  ViewController.swift
//  GoogleMapsExample
//
//  Created by Haris Jamil on 02/01/2020.
//  Copyright © 2020 Invotyx. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController,GMSMapViewDelegate,PlaceSelectedDelegate {
    
    
    
    @IBOutlet weak var map_VIEW: UIView!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet var markerView:UIImageView!
    @IBOutlet weak var searchBtn: UIButton!
    
    var selectedLocation = CLLocationCoordinate2D(latitude: 100000, longitude: 100000)
    let marker = GMSMarker()
    var mapView : GMSMapView?
    
    func selectedPlace(_ controller: SearchViewController, _ model: PlacesModel) {
        selectedLocation = CLLocationCoordinate2D(latitude: model.lat, longitude: model.lng)
        
        self.searchBtn.setTitle(model.name, for: .normal)
        
        let camera = GMSCameraPosition.camera(withLatitude: model.lat, longitude: model.lng, zoom: 15.0)
        
        mapView?.moveCamera(GMSCameraUpdate.setCamera(camera))
        controller.navigationController?.popViewController(animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        loadMap()
        
    }
    
    
    
    func loadMap(){
        
        let camera = GMSCameraPosition.camera(withLatitude: 33.66291013832151, longitude: 72.21078850328922, zoom: 15.0)
        
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView!)
        self.view.addSubview(selectBtn)
        self.view.addSubview(searchBtn)
        mapView!.delegate = self
        
        
        let image : UIImage = UIImage(named:"icons8-map_pin")!
        markerView = UIImageView(image: image)
        markerView.frame = CGRect(x:((mapView!.center.x) - 16), y: ((mapView!.center.y) - 16), width: 32, height: 32)
        mapView!.addSubview(markerView)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Search" {
            let controller  = segue.destination as! SearchViewController
            controller.delegate = self
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        selectedLocation = CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude)
        print("Latitude:\(selectedLocation.latitude),\n Longitude: \(selectedLocation.longitude)")
        
        let placeName = GMSGeocoder()
        
        placeName.reverseGeocodeCoordinate(selectedLocation) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            let addressLabel = lines.joined(separator: "\n")
            print(addressLabel)
            self.searchBtn.setTitle(addressLabel, for: .normal)
        }
        
        
    }
    @IBAction func searchTap(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        newViewController.delegate = self
        self.navigationController?.pushViewController(newViewController, animated: true)
//        self.present(newViewController, animated: true, completion: nil)
//        self.showDetailViewController(newViewController, sender: nil)
        //self.performSegue(withIdentifier: "Search", sender: nil)
    }
    
    @IBAction func selectedBtnClick(){
        if(selectedLocation.latitude != 100000){
            let alert = UIAlertController.init(title: "Selected Location", message: "Latitude:\(selectedLocation.latitude),\n Longitude: \(selectedLocation.longitude)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}



extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor
            {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

