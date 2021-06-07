//
//  SearchViewController.swift
//  wemap
//
//  Created by Nguyen Hoan on 28/05/2021.
//

import UIKit
import CoreLocation
import WeMapSDK


enum SearchStatus {
    case start
    case end
}

enum Vehicle {
    case car
    case bike
    case person
}

class SearchViewController: UIViewController {
    @IBOutlet weak var tfStart: UITextField!
    @IBOutlet weak var tfEnd: UITextField!
    @IBOutlet weak var vStart: UIView!
    @IBOutlet weak var vEnd: UIView!
    @IBOutlet weak var vTop: UIView!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCar: UIButton!
    @IBOutlet weak var btnBike: UIButton!
    @IBOutlet weak var btnPerson: UIButton!
    
    var isSearching: Bool = false {
        didSet {
            
        }
    }
    
    var resutlsSearch: [WeMapPlace] = []
    var wemapView: WeMapView = WeMapView()
    
    var searchStatus: SearchStatus = .start
    var vehicle: Vehicle = .car {
        didSet {
            if vehicle == .car {
                btnCar.setTitle(" V", for: .normal)
                btnBike.setTitle("", for: .normal)
                btnPerson.setTitle("", for: .normal)
            } else if vehicle == .bike {
                btnCar.setTitle(" ", for: .normal)
                btnBike.setTitle(" V", for: .normal)
                btnPerson.setTitle("", for: .normal)
            } else {
                btnCar.setTitle("", for: .normal)
                btnBike.setTitle("", for: .normal)
                btnPerson.setTitle(" V", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vStart.layer.cornerRadius = 12
        vEnd.layer.cornerRadius = 12
        vStart.layer.borderWidth = 1
        vEnd.layer.borderWidth = 1
        let wemapView = WeMapView(frame: view.bounds)
        

                wemapView.setCenter(CLLocationCoordinate2D(latitude: 21.0266469, longitude: 105.7615744), zoomLevel: 12, animated: false)
                wemapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.addSubview(wemapView)
                wemapView.delegate = self
//        if #available(iOS 13.0, *) {
//            vStart.layer.borderColor = CGColor.init(red: 120, green: 135, blue: 145, alpha: 1)
//        } else {
//            // Fallback on earlier versions
//        }
//        if #available(iOS 13.0, *) {
//            vEnd.layer.borderColor = CGColor.init(red: 120, green: 135, blue: 145, alpha: 1)
//        } else {
//            // Fallback on earlier versions
//        }
        view.bringSubviewToFront(vTop)
        
        tableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func startAction(_ sender: Any) {
        self.tfStart.becomeFirstResponder()
    }
    
    @IBAction func endAction(_ sender: Any) {
        self.tfEnd.becomeFirstResponder()
    }
    
    @IBAction func car(_ sender: Any) {
        vehicle = .car
    }
    @IBAction func bike(_ sender: Any) {
        vehicle = .bike
    }
    @IBAction func person(_ sender: Any) {
        vehicle = .person
    }
    
    
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as? ResultCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.lblName.text = resutlsSearch[indexPath.row].placeName
        cell.lblDistrict.text = setAddress(place: resutlsSearch[indexPath.row])
        return cell
    }
    
    func setAddress(place: WeMapPlace) -> String{
        var rs: [String] = []
        if !place.housenumber.isEmpty {
            rs.append(place.housenumber)
        }
        if !place.street.isEmpty {
            rs.append(place.street)
        }
        if !place.district.isEmpty {
            rs.append(place.district)
        }
        if !place.city.isEmpty {
            rs.append(place.city)
        }
        if rs.isEmpty {
            return ""
        }
        return rs.joined(separator: ", ")
    }
    
    
}


extension SearchViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == self.tfStart {
            self.searchStatus = .start
        } else {
            self.searchStatus = .end
        }
        
        let completeHandler: ([WeMapPlace]) -> Void = { wemapPlaces in
            if wemapPlaces.isEmpty {
                DispatchQueue.main.async {
                    self.resutlsSearch = []
                    self.tableView.reloadData()
                }
                return
            }
            self.resutlsSearch = wemapPlaces
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
       let wemapSearch = WeMapSearch()

       //gioi han so luong du lieu tra ve
       let wemapOptions = WeMapSearchOptions(10, focusPoint: CLLocationCoordinate2D(latitude: 21.031772, longitude: 105.799508), latLngBounds: WeMapLatLonBounds(minLon: 104.799508, minLat: 20.031772, maxLon: 105.799508, maxLat: 21.031772))
        
        
        if textField.text ?? "" != "" {
            wemapSearch.search(textField.text ?? "", wemapSearchOptions: wemapOptions, completeHandler: completeHandler)
        }
        
    }
}


extension SearchViewController:  WeMapViewDelegate {
    func WeMapViewDidFinishLoadingMap(_ wemapView: WeMapView) {
        print("done")
    }
}
