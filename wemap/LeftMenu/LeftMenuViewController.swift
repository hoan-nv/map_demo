import UIKit


class LeftMenuViewController:
    UIViewController {
// MARK: --Out let
    @IBOutlet weak var vAround: UIView!
    @IBOutlet weak var tblMenu: UITableView!

//   MARK: --var
    
    var arrName = ["10 chỗ sửa xe gần nhất", "!0 quán Circle K gần nhất", "10 cây xăng gần nhất"]
    
//    MARK: --lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    

    
    func setupView() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        //
        tblMenu.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        //
        tblMenu.delegate = self
        tblMenu.dataSource = self
        tblMenu.contentInset.top = 30
        tblMenu.contentInset.bottom = 30
        setRadiusTopRight()

    }
    
    
    
    func setRadiusTopRight() {
        vAround.clipsToBounds = true
        vAround.layer.cornerRadius = 20
        vAround.layer.maskedCorners = [.layerMaxXMinYCorner]
    }
    

}
extension LeftMenuViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuCell else {
            return UITableViewCell()
        }
        cell.lblTitle.text = arrName[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
           
        }
    }
    
   
}
