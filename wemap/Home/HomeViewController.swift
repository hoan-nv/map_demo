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

enum Mode {
    case Normal
    case TenPositon
}



class HomeViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var vLocator: UIView!
    @IBOutlet weak var vSearch: UIView!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var vSearchRoad: UIView!
    @IBOutlet weak var actionBackMode: UIButton!
    
    @IBAction func ActionBack(_ sender: Any) {
        self.mode = .Normal
        self.wemapView.removeAllAnnotation()
        self.resetDestPosition()
    }
    
    public var mode: Mode = .Normal {
        didSet {
            if mode == .Normal  {
                vSearch.isHidden = false
//                vLocator.isHidden = false
                vSearchRoad.isHidden = false
            } else {
                vSearch.isHidden = true
//                vLocator.isHidden = true
                vSearchRoad.isHidden = true
//                tableView.isHidden = true
            }
        }
    }
    
    var menu = SideMenuNavigationController(rootViewController: LeftMenuViewController())
    
    let imageNameCirclek = "cart.circle.fill"
    let imageNameFixMotobike = "gearshape.fill"
    let imageNameFuel = "cylinder.fill"

    let leftMenu = LeftMenuViewController()
    
    var typePosition: typePositions = .CircleK

    let locationManager = CLLocationManager()

    var centerMyhome: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 21.0266469, longitude: 105.7615744)
    
    var wemapView: WeMapView = WeMapView()
    
    var resutlsSearch: [WeMapPlace] = []
    var resultPoints: [CLLocationCoordinate2D] = []
    
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
            self.centerMyhome = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
        view.bringSubviewToFront(actionBackMode)
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
        leftMenu.delegate = self
    
        
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
            if let image = UIImage(systemName: "circlebadge.fill") {
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
        wemapView.addTrafficLayer()
        wemapView.addSatelliteLayer()
        wemapView.removeTrafficLayer()
        wemapView.removeSatelliteLayer()

    }

//    func wemapView(_ wemapView: WeMapView, annotationCanShowCallout annotation: WeMapAnnotation) -> Bool {
//        return true
//    }

    // MARK: - Feature interaction
        @objc func handleMapTap(sender: UITapGestureRecognizer) {
            self.tfSearch.endFloatingCursor()
            self.tfSearch.endEditing(true)
            let point = sender.location(in: sender.view!)
            let touchCoordinate = wemapView.convert(point, toCoordinateFrom: sender.view!)
            
            if sender.state == .ended {
                if mode == .Normal {

                    wemapView.removeAllAnnotation()

                    // Try matching the exact point first.
                    wemapView.selectAnnotation(WeMapPointAnnotation(touchCoordinate), animated: false, completionHandler: {})

                    tfSearch.text = String(touchCoordinate.latitude) + ", " + String(touchCoordinate.longitude)
                } else {

                    let layerIdentifiers: Set = ["dest-position"]
                                // Try matching the exact point first.
                    let point = sender.location(in: sender.view!)
//                    for pointAnnotation in wemapView.visibleFeatures(at: point, styleLayerIdentifiers: layerIdentifiers) {
//                        wemapView.selectAnnotation(pointAnnotation, animated: false, completionHandler: {})
//                        return
//                    }

                    let touchCoordinate = wemapView.convert(point, toCoordinateFrom: sender.view!)
                    let touchLocation = CLLocation(latitude: touchCoordinate.latitude , longitude: touchCoordinate.longitude )

                    // Otherwise, get all features within a rect the size of a touch (44x44).
                    let touchRect = CGRect(origin: point, size: .zero).insetBy(dx: -22.0, dy: -22.0)
                    let possibleFeatures = wemapView.visibleFeatures(inCGRect: touchRect, styleLayerIdentifiers: Set(layerIdentifiers))

                    // Select the closest feature to the touch center.
                    let closestFeatures = possibleFeatures?.sorted(by: {
                        return CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude).distance(from: touchLocation) < CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude).distance(from: touchLocation)
                    })
                    if let feature = closestFeatures?.first {
//                        wemapView.selectAnnotation(feature, animated: false, completionHandler: {})
                        let nextVC = RouteViewController()
                        nextVC.endLocation = feature.coordinate
                        self.navigationController?.pushViewController(nextVC, animated: true)
                        return
                    }
                }

            }
        }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let completeHandler: ([WeMapPlace]) -> Void = { [weak self] wemapPlaces in
            guard let `self` = self else {return}
            if wemapPlaces.isEmpty {
                DispatchQueue.main.async {
                    self.resutlsSearch = []
                    self.tableView.reloadData()
                }
                return
            }
            let start = CLLocation(latitude: self.centerMyhome.latitude, longitude: self.centerMyhome.longitude)
            func sortPositon(pl1: WeMapPlace,pl2: WeMapPlace) -> Bool {
                let end1 = CLLocation(latitude: pl1.location.latitude, longitude: pl1.location.longitude)
                let end2 = CLLocation(latitude: pl2.location.latitude, longitude: pl2.location.longitude)
                return start.distance(from: end1) < start.distance(from: end2)
                
            }
            self.resutlsSearch = wemapPlaces.sorted(by: sortPositon)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        if self.statusRightBar == .exten {
            changeStateRight()
        }
        
        
       let wemapSearch = WeMapSearch()

       //gioi han so luong du lieu tra ve
       let wemapOptions = WeMapSearchOptions(24, focusPoint: CLLocationCoordinate2D(latitude: 21.031772, longitude: 105.799508), latLngBounds: WeMapLatLonBounds(minLon: 104.799508, minLat: 20.031772, maxLon: 105.799508, maxLat: 21.031772))
    
        
        
        if textField.text ?? "" != "" {
            wemapSearch.search(textField.text ?? "", wemapSearchOptions: wemapOptions, completeHandler: completeHandler)
        }
    }
    
    
    func resetDestPosition() {
        wemapView.removeLayer("dest-position")
        wemapView.removeSource("dest-source")
    }
    
    
    func setDestPosition() {
        resetDestPosition()
        let coordinates = self.resultPoints

                // Fill an array with point annotations and add it to the map.
                var pointAnnotations = [WeMapPointAnnotation]()
                for coordinate in coordinates {
                    let point = WeMapPointAnnotation(coordinate)
                    point.title = "\(coordinate.latitude), \(coordinate.longitude)"
                    pointAnnotations.append(point)
                }
                // Create a data source to hold the point data
                let shapeSource = WeMapShapeSource(identifier: "dest-source", points: pointAnnotations)

                // Create a style layer for the symbol
                let shapeLayer = WeMapSymbolStyleLayer(identifier: "dest-position", source: shapeSource)

                // Add the image to the style's sprite
        var imageName = self.imageNameCirclek
        if self.typePosition == .FixMotobike {
            imageName = self.imageNameFixMotobike
        }
        if self.typePosition == .Fuel {
            imageName = self.imageNameFuel
        }
        if #available(iOS 13.0, *) {
            if let image = UIImage(systemName: imageName) {
                wemapView.setImage(image, forName: "dest-image")
            }
        } else {
            // Fallback on earlier versions
        }

                // Tell the layer to use the image in the sprite
                shapeLayer.iconImageName = NSExpression(forConstantValue: "dest-image")

                // Add the source and style layer to the map
                wemapView.addSource(shapeSource)
                wemapView.addLayer(shapeLayer)
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
        let start = CLLocation(latitude: centerMyhome.latitude, longitude: centerMyhome.longitude)
        let end = CLLocation(latitude: resutlsSearch[indexPath.row].location.latitude, longitude: resutlsSearch[indexPath.row].location.longitude)
        cell.lblDistant.text = String(Double(round(start.distance(from: end)/1000 * 100) / 100)) + " km"
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


extension HomeViewController: LeftMenuViewControllerDelegate {
    func setPosition(type: typePositions) {
        self.mode = .TenPositon
        self.wemapView.removeAllAnnotation()
        let wemapSearch = WeMapSearch()

        //gioi han so luong du lieu tra ve
        let wemapOptions = WeMapSearchOptions(24, focusPoint: centerMyhome, latLngBounds: WeMapLatLonBounds(minLon: 104.799508, minLat: 20.031772, maxLon: 105.799508, maxLat: 21.031772))
        var searchText = "circle k"
        if type == .CircleK {
            searchText = "circle k"
        }
        if type == .FixMotobike {
            searchText = "sữa xe máy"
        }
        if type == .Fuel {
            searchText = "cây xăng"
        }
        
        self.typePosition = type
        
        wemapSearch.search(searchText, wemapSearchOptions: wemapOptions ) {[weak self] wemapPlace in
            guard let `self` = self else {return}
            
            let start = CLLocation(latitude: self.centerMyhome.latitude, longitude: self.centerMyhome.longitude)
            func sortPositon(pl1: WeMapPlace,pl2: WeMapPlace) -> Bool {
                let end1 = CLLocation(latitude: pl1.location.latitude, longitude: pl1.location.longitude)
                let end2 = CLLocation(latitude: pl2.location.latitude, longitude: pl2.location.longitude)
                return start.distance(from: end1) < start.distance(from: end2)
            }
            let places = wemapPlace.sorted(by: sortPositon).prefix(10)
            
            self.wemapView.selectAnnotation(WeMapPointAnnotation(self.centerMyhome), animated: false, completionHandler: {})
            self.resultPoints = []
            
            for place in places {
                self.resultPoints.append(place.location)
//                self.wemapView.selectAnnotation(WeMapPointAnnotation(place.location), animated: false, completionHandler: {})
            }
            
            self.setDestPosition()
        }
    }
    
    func wemapView(_ weMapView: WeMapView, annotationCanShowCallout annotation: WeMapAnnotation) -> Bool {
        return true
    }
    
    func wemapView(_ weMapView: WeMapView, annotation: WeMapAnnotation, calloutAccessoryControlTapped control: UIControl) {
        print("tap tap")
    }

    
    
}
