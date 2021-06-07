//
//  HomeViewController.swift
//  wemap
//
//  Created by Nguyen Hoan on 26/05/2021.
//

import UIKit
import CoreLocation
import WeMapSDK
import SideMenu

enum RightBarButtonStatus {
    case exten
    case back
}



class HomeViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var vLocator: UIView!
    @IBOutlet weak var vSearch: UIView!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var vSearchRoad: UIView!
    
    var menu = SideMenuNavigationController(rootViewController: LeftMenuViewController())
    

    
    let leftMenu = LeftMenuViewController()
    
    let locationManager = CLLocationManager()

    
    let centerMyhome: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 20.993893749513248, longitude: 105.82176090675364)
    
    var wemapView: WeMapView = WeMapView()
    
    var resutlsSearch: [WeMapPlace] = []
    
    var statusRightBar: RightBarButtonStatus = .exten {
        didSet {
            if self.statusRightBar == .exten {
                if #available(iOS 13.0, *) {
                    btnRight.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
                } else {
                    // Fallback on earlier versions
                }
                wemapView.isHidden = false
                vLocator.isHidden = false
                vSearchRoad.isHidden = false
            } else {
                if #available(iOS 13.0, *) {
                    btnRight.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
                } else {
                    // Fallback on earlier versions
                }
                wemapView.isHidden = true
                vLocator.isHidden = true
                vSearchRoad.isHidden = true
            }
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    
        
        
        
        
        
        
        
        wemapView = WeMapView(frame: view.bounds)

        wemapView.setCenter(centerMyhome, zoomLevel: 12, animated: true)
        wemapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(wemapView)
        view.bringSubviewToFront(vLocator)
        view.bringSubviewToFront(vSearch)
        view.bringSubviewToFront(vSearchRoad)
        vSearch.setShadowRadiusView()
        vSearch.layer.cornerRadius = 12
        vLocator.setShadowRadiusView()
        vLocator.layer.cornerRadius = 25
        vSearchRoad.setShadowRadiusView()
        vSearchRoad.layer.cornerRadius = 25
        wemapView.delegate = self
        tfSearch.delegate = self
        
    
        
        tableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        tableView.delegate = self
        tableView.dataSource = self

        
        
        
        menu = SideMenuNavigationController(rootViewController: leftMenu)
        menu.leftSide = true
        menu.presentationStyle = .menuSlideIn
        menu.statusBarEndAlpha = 0
        menu.menuWidth = 300
        self.menu.presentationStyle.presentingEndAlpha = 0.5
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view, forMenu: .left)
        
    }

    @IBAction func extendAction(_ sender: Any) {

        wemapView.isHidden = false
        if self.statusRightBar == .back {
            changeStateRight()
        } else {
            if self.statusRightBar == .exten {
                self.present(self.menu, animated: true, completion: nil)
            }
        }
        
        
       
    }
    
    @IBAction func localAction(_ sender: Any) {
        wemapView.setCenter(centerMyhome, zoomLevel: 15, animated: true)
    }
    
    
    
    @IBAction func searchRoad(_ sender: Any) {
        let nextVC = SearchViewController()
        navigationController?.pushViewController(nextVC, animated: true)
        
    }

    
    func changeStateRight() {
        if self.statusRightBar == .exten {
            self.statusRightBar = .back
        } else {
            self.statusRightBar = .exten
        }
    }

}


extension HomeViewController: WeMapViewDelegate {
    func WeMapViewDidFinishLoadingMap(_ wemapView: WeMapView) {
        let coordinates = [
            centerMyhome
        ]
        
        // Fill an array with point annotations and add it to the map.
        var pointAnnotations = [WeMapPointAnnotation]()
        for coordinate in coordinates {
            let point = WeMapPointAnnotation(coordinate)
            point.title = "\(coordinate.latitude), \(coordinate.longitude)"
            pointAnnotations.append(point)
        }
        // Create a data source to hold the point data
        let shapeSource = WeMapShapeSource(identifier: "home-source", points: pointAnnotations)

        // Create a style layer for the symbol
        let shapeLayer = WeMapSymbolStyleLayer(identifier: "home-symbols", source: shapeSource)

        // Add the image to the style's sprite
        if #available(iOS 13.0, *) {
            if let image = UIImage(systemName: "line.horizontal.3") {
                wemapView.setImage(image, forName: "icon-house")
            }
        } else {
            // Fallback on earlier versions
        }

        // Tell the layer to use the image in the sprite
        shapeLayer.iconImageName = NSExpression(forConstantValue: "icon-house")

        // Add the source and style layer to the map
        wemapView.addSource(shapeSource)
        wemapView.addLayer(shapeLayer)

        // Add a single tap gesture recognizer. This gesture requires the built-in WeMapView tap gestures (such as those for zoom and annotation selection) to fail.
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:)))
        for recognizer in wemapView.getGestureRecognizers() where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        wemapView.addGestureRecognizer(singleTap)

    }

    func wemapView(_ wemapView: WeMapView, annotationCanShowCallout annotation: WeMapAnnotation) -> Bool {
        return true
    }
    
    // MARK: - Feature interaction
        @objc func handleMapTap(sender: UITapGestureRecognizer) {
            if sender.state == .ended {
                wemapView.removeAllAnnotation()
                
//                wemapView.deselectFirstAnnotation(animated: true)
                // Limit feature selection to just the following layer identifiers.
                let layerIdentifiers: Set = ["home-symbols"]
                // Try matching the exact point first.
                let point = sender.location(in: sender.view!)
                
                for pointAnnotation in wemapView.visibleFeatures(at: point, styleLayerIdentifiers: layerIdentifiers) {
                    wemapView.selectAnnotation(pointAnnotation, animated: false, completionHandler: {}) 
                    return
                }

                let touchCoordinate = wemapView.convert(point, toCoordinateFrom: sender.view!)
                let touchLocation = CLLocation(latitude: touchCoordinate.latitude , longitude: touchCoordinate.longitude )

                // Otherwise, get all features within a rect the size of a touch (44x44).
                let touchRect = CGRect(origin: point, size: .zero).insetBy(dx: -22.0, dy: -22.0)
                let possibleFeatures = wemapView.visibleFeatures(inCGRect: touchRect, styleLayerIdentifiers: Set(layerIdentifiers))
                
               
                

                // Select the closest feature to the touch center.
                let closestFeatures = possibleFeatures?.sorted(by: {
                    return CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude).distance(from: touchLocation) < CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude).distance(from: touchLocation)
                })
//                if let feature = closestFeatures?.first {
//                    wemapView.selectAnnotation(feature, animated: false, completionHandler: {})
//                    return
//                }
//                var ano: [WeMapAnnotation] = []
//                ano.append(WeMapPointAnnotation(touchCoordinate))
                wemapView.selectAnnotation(WeMapPointAnnotation(touchCoordinate), animated: false, completionHandler: {})
                
                tfSearch.text = String(touchCoordinate.latitude) + ", " + String(touchCoordinate.longitude)
                
                // If no features were found, deselect the selected annotation, if any.
                
                
                
//                let pointAnnonation: WeMapPointAnnotation = WeMapPointAnnotation(CLLocationCoordinate2D(latitude: 21.0266469, longitude: 105.7615744))
//                let shapeSource = WeMapShapeSource(identifier: "dest", point: pointAnnonation)
//                if #available(iOS 13.0, *) {
//                    wemapView.setImage(UIImage(systemName: "line.horizontal.3")!, forName: "dest")
//                } else {
//                    // Fallback on earlier versions
//                }
//                let shapeLayer = WeMapSymbolStyleLayer(identifier: "dest", source: shapeSource)
//                wemapView.addSource(shapeSource)
//                wemapView.addLayer(shapeLayer)
            }
        }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
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
        if self.statusRightBar == .exten {
            changeStateRight()
        }
        
        
       let wemapSearch = WeMapSearch()

       //gioi han so luong du lieu tra ve
       let wemapOptions = WeMapSearchOptions(10, focusPoint: CLLocationCoordinate2D(latitude: 21.031772, longitude: 105.799508), latLngBounds: WeMapLatLonBounds(minLon: 104.799508, minLat: 20.031772, maxLon: 105.799508, maxLat: 21.031772))
        
        
        if textField.text ?? "" != "" {
            wemapSearch.search(textField.text ?? "", wemapSearchOptions: wemapOptions, completeHandler: completeHandler)
        }
        
       
        
        
       //        wemapSearch.reverse(CLLocationCoordinate2D(latitude: 21.031772, longitude: 105.799508), wemapSearchOptions: wemapOptions, completeHandler: completeHandler)
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resutlsSearch.count
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeStateRight()
        wemapView.setCenter(resutlsSearch[indexPath.row].location, zoomLevel: 16, animated: true)
        wemapView.removeAllAnnotation()
        wemapView.selectAnnotation(WeMapPointAnnotation(resutlsSearch[indexPath.row].location), animated: false, completionHandler: {})
        self.tfSearch.text = resutlsSearch[indexPath.row].placeName
        
        
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
