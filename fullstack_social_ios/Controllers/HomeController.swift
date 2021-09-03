//
//  HomeController.swift
//  fullstack_social_ios
//
//  Created by Andrey on 28.08.2021.
//

import LBTATools
import WebKit
import Alamofire
import SDWebImage

class HomeController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // Terminal run ifconfig
    // 192.168.2.183
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [
            .init(title: "Fetch posts", style: .plain, target: self, action: #selector(fetchPosts)),
            .init(title: "Create post", style: .plain, target: self, action: #selector(createPost))
        ]
        
        navigationItem.leftBarButtonItem = .init(title: "Log In", style: .plain, target: self, action: #selector(handleLogin))
    }
    
    @objc fileprivate func createPost() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        dismiss(animated: true) {
            let url = "http://localhost:1337/post"
            AF.upload(multipartFormData: { (formData) in
                // post text
                formData.append(Data("Coming from iPhone Sim".utf8), withName: "postBody")
                
                // post image
                guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
                formData.append(imageData, withName: "imagefile", fileName: "doesntMatterSoMuch", mimeType: "image/jpg")
            }, to: url).uploadProgress { (progress) in
                print("Upload progress: \(progress.fractionCompleted)")
            }.responseJSON { json in
                if let err = json.error {
                    print("Failed to hit server: ", err)
                    return
                }
                
                if let code = json.response?.statusCode, code >= 300 {
                    print("Failed upload with status: ", code)
                    return
                }
                
                let respString = String(data: json.data ?? Data(), encoding: .utf8)
                print("Successfully created post, here is the response:")
                print(respString ?? "")
                
                self.fetchPosts()
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    fileprivate func showCookies() {
        HTTPCookieStorage.shared.cookies?.forEach({ (cookie) in
            print(cookie)
        })
    }
    
    @objc fileprivate func handleLogin() {
        print("Show login and sign up pages")
        let navController = UINavigationController(rootViewController: LoginController())
        present(navController, animated: true)
    }
    
    @objc fileprivate func fetchPosts() {
        Service.shared.fetchPosts { (res) in
            switch res {
            case .failure(let err):
                print("Failed to fetch posts:", err)
            case .success(let posts):
                self.posts = posts
                self.tableView.reloadData()
            }
        }
        print("Maybe finished uploading")
    }
    
    var posts = [Post]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.user.fullName
        cell.textLabel?.font = .boldSystemFont(ofSize: 14)
        cell.detailTextLabel?.text = post.text
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.imageView?.sd_setImage(with: URL(string: post.imageUrl))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

}
