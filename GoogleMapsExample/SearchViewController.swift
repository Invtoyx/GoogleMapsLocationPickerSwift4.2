//
//  SearchViewController.swift
//  GoogleMapsExample
//
//  Created by Haris Jamil on 03/01/2020.
//  Copyright © 2020 Invotyx. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class SearchViewController: UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var placesTable: UITableView!
    
    var address = ""
    var pincode = ""
    var city = ""
    var state = ""
    var country = ""
    
    var placesList: Array<PlacesModel> = Array()
    
    weak var delegate: PlaceSelectedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }

    
    func initView(){
        
        searchView.delegate = self
        placesTable.delegate = self
        placesTable.dataSource = self
        searchView.becomeFirstResponder()
   
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchBar.text as String? ?? ""
        
        if(text == ""){
            placesList.removeAll()
            
            self.placesTable.reloadData()
            self.placesTable.beginUpdates()
            self.placesTable.endUpdates()
            
        }else{
        
        let replaced = text.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        
        let geoCodingUrl = "https://maps.googleapis.com/maps/api/geocode/json?address=\(replaced)&key=\(google_maps_api_key)"
        
        
        Alamofire.request(geoCodingUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                
                let responseJson = response.result.value! as! NSDictionary
                
                
            
                if let results = responseJson.object(forKey: "results")! as? [NSDictionary] {
                    if results.count > 0 {
                
                        for i in 0..<results.count{
                            
                            if let addressComponents = results[i]["address_components"]! as? [NSDictionary] {
                                self.address = results[i]["formatted_address"] as? String ?? ""
                                for component in addressComponents {
                                    if let temp = component.object(forKey: "types") as? [String] {
                                        if (temp[0] == "postal_code") {
                                            self.pincode = component["long_name"] as? String ?? ""
                                        }
                                        if (temp[0] == "locality") {
                                            self.city = component["long_name"] as? String ?? ""
                                        }
                                        if (temp[0] == "administrative_area_level_1") {
                                            self.state = component["long_name"] as? String ?? ""
                                        }
                                        if (temp[0] == "country") {
                                            self.country = component["long_name"] as? String ?? ""
                                        }
                                    }
                                }
                                
                                
                                let place = PlacesModel()
                                if let geometry = results[i]["geometry"] as? NSDictionary {
                                    if let location = geometry.value(forKey: "location") as? NSDictionary {
                                        
                                        place.name = self.address
                                        place.lat = location.value(forKey: "lat") as? Double ?? 0.0
                                        place.lng = location.value(forKey: "lng") as? Double ?? 0.0
                                        self.placesList.removeAll()
                                        self.placesList.append(place)
                                        
                             print("formatted add:\(self.address)")
                                    }
                                }
                                
                            }
                            
                            
                            //                            print("formatted add:\(place.name),\(place.lat),\(place.lng)")
                        }
                        
                        self.placesTable.reloadData()
                        self.placesTable.beginUpdates()
                        self.placesTable.endUpdates()
                    }
                   
                }
            case .failure(let error):
                print(error)
            }
        }
        }
        
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchView.endEditing(true)
    }

   
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.placesList.count
        
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Place", for: indexPath)
        
        let label = cell.viewWithTag(100) as! UILabel
        label.text = self.placesList[indexPath.row].name
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.placesList[indexPath.row]
        delegate?.selectedPlace(self, item)
        
    }
    
    
    
}

protocol PlaceSelectedDelegate: class {
    func selectedPlace(_ controller: SearchViewController,_ model:PlacesModel)
}
