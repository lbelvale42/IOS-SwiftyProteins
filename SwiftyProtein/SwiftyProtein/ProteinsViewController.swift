//
//  ProteinsViewController.swift
//  SwiftyProtein
//
//  Created by Lucas BELVALETTE on 11/9/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ProteinsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    var ligArr: [String]?
    var pdb: [String]?
    var searchController: UISearchController!
    var ligFiltered: [String]?
    var protein: Protein?

    override func viewWillAppear(_ animated: Bool) {
        self.searchController.searchBar.isHidden = false
        tableView.allowsSelection = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                ligArr = data.components(separatedBy: .newlines)
                ligArr!.removeLast()
                ligFiltered = ligArr
            } catch {
                print(error)
            }
        }
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.autocapitalizationType = .allCharacters
        self.tableView.tableHeaderView = searchController.searchBar
        
        // Do any additional setup after loading the view.
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! != "" {
            ligFiltered = ligArr?.filter { lig in
                return lig.contains(searchController.searchBar.text!.uppercased())
            }
            tableView.reloadData()
        }
        else {
            ligFiltered = ligArr
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goScene" {
            let vc = segue.destination as! SceneViewController
            vc.protein = self.protein
            vc.title = self.protein?.name!
        }
    }
    
    func requestPDBModel(protein: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request("https://files.rcsb.org/ligands/view/\(protein)_ideal.sdf").responseString {
            response in
            if response.response?.statusCode != 200 {
                let alert = UIAlertController(title: "Error", message: "Fail to load PDB File", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.tableView.allowsSelection = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            self.pdb = response.result.value!.components(separatedBy: .newlines)
            self.pdb?.removeFirst()
            self.pdb?.removeFirst()
            self.pdb?.removeFirst()
            var arr1 = self.pdb![0].components(separatedBy: .whitespacesAndNewlines).filter {
                $0 != ""
            }
            let nbAtom = Int(arr1[0])
            self.pdb?.removeFirst()
            arr1 = self.pdb![0].components(separatedBy: .whitespacesAndNewlines).filter {
                $0 != ""
            }
            var i = 0
            for x in self.pdb! {
                if i < nbAtom! {
                    if i == 0 {
                        if let x = Float(arr1[0]) {
                            if let y = Float(arr1[1]) {
                                if let z = Float(arr1[2]) {
                                        let atom = Atom(id: i + 1, x: x, y: y, z: z, mol: arr1[3])
                                        self.protein = Protein(name: protein, atom: atom)
                                }
                            }
                        }
                    }
                    else {
                        let arr = x.components(separatedBy: .whitespacesAndNewlines).filter {
                            $0 != ""
                        }
                        if arr[1] == "END" {
                            let alert = UIAlertController(title: "Error", message: "PDB File is corrupted", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.tableView.allowsSelection = true
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            return
                        }
                        else if let x = Float(arr[0]) {
                            if let y = Float(arr[1]) {
                                if let z = Float(arr[2]) {
                                    let atom = Atom(id: i + 1, x: x, y: y, z: z, mol: arr[3])
                                    self.protein?.addAtom(atom: atom)
                                }
                                else {
                                    let alert = UIAlertController(title: "Error", message: "PDB File is corrupted", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    self.tableView.allowsSelection = true
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    return
                                }
                            }
                            else {
                                let alert = UIAlertController(title: "Error", message: "PDB File is corrupted", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                self.tableView.allowsSelection = true
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                return
                            }
                        }
                        else {
                            let alert = UIAlertController(title: "Error", message: "PDB File is corrupted", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.tableView.allowsSelection = true
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            return
                        }
                    }
                }
                else {
                    let arr = x.components(separatedBy: .whitespacesAndNewlines).filter {
                        $0 != ""
                    }
                    if arr[1] == "END" {
                        break
                    }
                    else {
                        let arr3 = arr.map { (param) -> Int in
                            if let ret = Int(param) {
                                return ret
                            }
                            else {
                                let alert = UIAlertController(title: "Error", message: "PDB File is corrupted", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                self.tableView.allowsSelection = true
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                return 0
                            }
                        }
                        let connect = Connect(from: arr3[0], to: arr3[1], nbConnect: arr3[2])
                        self.protein?.addConnect(connect: connect)
                    }
                }
                i += 1
            }
            DispatchQueue.main.async {
                self.searchController.searchBar.isHidden = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.performSegue(withIdentifier: "goScene", sender: "")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        tableView.allowsSelection = false
        requestPDBModel(protein: (ligFiltered?[indexPath.row])!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProteinCell") as! ProteinTableViewCell
        let name = ligFiltered?[indexPath.row]
        cell.nameLabel.text = name
        cell.imageProtein.isHidden = true
        cell.activityMonitor.isHidden = false
        cell.activityMonitor.startAnimating()
        Alamofire.request("https://www3.rcsb.org/proxyimg/\(name!)_200.png").responseImage { response in
            if let image = response.result.value {
                cell.imageProtein.image = image
                cell.imageProtein.isHidden = false
                cell.activityMonitor.isHidden = true
                cell.activityMonitor.stopAnimating()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ligFiltered?.count)!
    }

}
