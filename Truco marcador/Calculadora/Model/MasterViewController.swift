/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import StoreKit

class MasterViewController: UITableViewController {
  
    
    @IBOutlet weak var loadingShow: UIActivityIndicatorView!
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
  
  var products: [SKProduct] = []
    
//    override func viewWillAppear(_ animated: Bool) {
//        loadingShow.startAnimating()
//        loadingShow.alpha = 1
//    }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Produtos"
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(MasterViewController.reload), for: .valueChanged)
    
    let restoreButton = UIBarButtonItem(title: "Restaurar",
                                        style: .plain,
                                        target: self,
                                        action: #selector(MasterViewController.restoreTapped(_:)))
    navigationItem.rightBarButtonItem = restoreButton
    
    NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.handlePurchaseNotification(_:)),
                                           name: .IAPHelperPurchaseNotification,
                                           object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    reload()
  }
    
    override func viewWillDisappear(_ animated: Bool) {
        if RazeFaceProducts.store.isProductPurchased("NoAdds") {
            print("Comprado")
            UserDefaults.standard.set("Purshed", forKey:"NoAdds")
        }
    }
  
    @IBOutlet weak var teste: UILabel!
    @objc func reload() {
    products = []
    
    tableView.reloadData()
    
    RazeFaceProducts.store.requestProducts{ [weak self] success, products in
      guard let self = self else { return }
      if success {
        self.products = products!
        sleep(30)
        self.teste.text = self.products[0].productIdentifier
//        self.tableView.reloadData()
      }
        
//      self.refreshControl?.endRefreshing()
    }
  }
  
  @objc func restoreTapped(_ sender: AnyObject) {
    RazeFaceProducts.store.restorePurchases()
  }

  @objc func handlePurchaseNotification(_ notification: Notification) {
    guard
      let productID = notification.object as? String,
      let index = products.index(where: { product -> Bool in
        product.productIdentifier == productID
      })
    else { return }

    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
  }
}

// MARK: - UITableViewDataSource

extension MasterViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(products.count > 0) {
        loadingShow.stopAnimating()
        loadingShow.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        loadingShow.alpha = 0
    }
    return products.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    let product = products[(indexPath as NSIndexPath).row]
    
    cell.textLabel?.text = product.localizedTitle
//    cell.buyButtonHandler = { product in
//      RazeFaceProducts.store.buyProduct(product)
//    }
    
    if(loadingShow.alpha > 0) {
        loadingShow.stopAnimating()
        loadingShow.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        loadingShow.alpha = 0
    }
    
    return cell
  }
}
