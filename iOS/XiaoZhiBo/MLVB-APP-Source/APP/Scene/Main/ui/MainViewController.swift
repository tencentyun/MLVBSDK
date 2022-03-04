//
//  MainViewController.swift
//  TRTCScene
//
//  Created by adams on 2021/5/11.
//

import UIKit
import Toast_Swift
import ImSDK_Plus
import TUIPusher
import TUICore

#if DEBUG
let SdkBusiId = 18069
#else
let SdkBusiId = 18070
#endif

class MainViewController: UIViewController {
    
    lazy var logPickerView: UIPickerView = {
        let pickView = UIPickerView.init(frame: .zero)
        pickView.dataSource = self
        pickView.delegate = self
        return pickView
    }()
    
    lazy var logUploodView: UIView = {
        let uploadView = UIView.init(frame: .zero)
        uploadView.backgroundColor = .darkGray
        uploadView.isHidden = true
        return uploadView
    }()
    
    lazy var uploadButton: UIButton = {
        let uploadButton = UIButton.init(type: .custom)
        uploadButton.setTitle(MainLocalize("App.PortalViewController.sharelog"), for: .normal)
        uploadButton.titleLabel?.adjustsFontSizeToFitWidth = true
        return uploadButton
    }()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
        flowLayout.itemSize = CGSize.init(width: view.bounds.width - 40, height: 144)
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.reuseIdentifier)
        collectionView.register(MainKaraokeCollectionViewCell.self, forCellWithReuseIdentifier: MainKaraokeCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var descLabel: UILabel = {
        let descLabel = UILabel.init(frame: .zero)
        descLabel.font = UIFont.systemFont(ofSize: 14)
        descLabel.textAlignment = .center
        descLabel.textColor = UIColor.gray
        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.text = MainLocalize("Demo.TRTC.Home.appusetoshowfunc")
        return descLabel
    }()
    
    lazy var backBtn: UIButton = {
        let backBtn = UIButton.init(type: .custom)
        backBtn.setTitle(MainLocalize("Demo.TRTC.Portal.Home.logout"), for: .normal)
        backBtn.setTitleColor(UIColor.black, for: .normal)
        backBtn.titleLabel?.font = UIFont.init(name: "PingFangSC-Regular", size: 16)
        backBtn.sizeToFit()
        return backBtn
    }()
    
    var logFilesArray: [String] = []
    lazy var mainMenuItems: [MainMenuItemModel] = {
        return [
            MainMenuItemModel(imageName: "main_home_showlive",
                              title: MainLocalize("Demo.TRTC.Portal.Main.showLiveTitle"),
                              content: MainLocalize("Demo.TRTC.Portal.Main.showLiveDesc"),
                              selectHandle: { [weak self] in
                guard let `self` = self else { return }
                self.gotoShowLiveViewController()
            })]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaviBar()
        setupViewHierarchy()
        setupViewConstraints()
        bindInteraction()
        bindCallingModule()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupToast()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        }
        return .default
    }
    
    override var prefersStatusBarHidden: Bool { false }
    
    private func bindCallingModule() {
        guard let loginUserId = ProfileManager.sharedManager().getUserID() else {
            debugPrint("not Login")
            return
        }
        let userSig = ProfileManager.sharedManager().getUserSig()
        //        TUILogin.`init`(Int32(SDKAPPID))
        //        TUILogin.login(loginUserId, userSig: userSig) {
        //        } fail: { _, _ in
        //        }
    }
}

extension MainViewController {
    
    private func setupNaviBar() {
        view.backgroundColor = UIColor.init("F4F5F9")
        navigationController?.navigationBar.topItem?.title = .titleText
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black,
                                                                   NSAttributedString.Key.font:UIFont.init(name: "PingFangSC-Semibold", size: 18)!]
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        let item = UIBarButtonItem.init(customView: backBtn)
        navigationItem.rightBarButtonItems = [item]
    }
    
    private func setupViewHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(logUploodView)
        logUploodView.addSubview(uploadButton)
        logUploodView.addSubview(logPickerView)
    }
    
    private func setupViewConstraints() {
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        logUploodView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(view.bounds.height * 0.25)
            make.width.equalToSuperview()
            make.height.equalTo(view.bounds.height * 0.5)
        }
        
        uploadButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        logPickerView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(logUploodView).multipliedBy(0.8)
        }
    }
    
    private func bindInteraction() {
        uploadButton.addTarget(self, action: #selector(onShareUploadLog(sender:)), for: .touchUpInside)
        backBtn.addTarget(self, action: #selector(logout(sender:)), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(tapGesture:)))
        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
        
        let pressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(pressGesture:)))
        pressGesture.minimumPressDuration = 2.0
        pressGesture.numberOfTouchesRequired = 1
        navigationController?.navigationBar.addGestureRecognizer(pressGesture)
        
        tapGesture.require(toFail: pressGesture)
    }
}

//MARK: 跳转到
extension MainViewController {
    private func gotoShowLiveViewController() {
        let viewModel = ShowLiveListViewModel.init()
        let showLiveListViewController = ShowLiveListViewController.init(viewModel: viewModel)
        showLiveListViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(showLiveListViewController, animated: true)
    }
    
    private func gotoShopLiveViewController() {
        view.makeToast("更多功能，敬请期待")
    }
}

extension MainViewController {
    
    @objc private func onShareUploadLog(sender: UIButton) {
        let row = logPickerView.selectedRow(inComponent: 0)
        if row < logFilesArray.count {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let logDoc = paths.first! + "/log"
            let logPath = logDoc + "/\(self.logFilesArray[row])"
            let shareObj = URL.init(fileURLWithPath: logPath)
            let activityView = UIActivityViewController.init(activityItems: [shareObj], applicationActivities: nil)
            present(activityView, animated: true) {
                self.logUploodView.isHidden = true
            }
        }
    }
    
    @objc private func handleTap(tapGesture: UITapGestureRecognizer) {
        logUploodView.isHidden = true
    }
    
    @objc private func handleLongPress(pressGesture: UILongPressGestureRecognizer) {
        if pressGesture.state == .began {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let logDoc = paths.first! + "/log"
            let fileManager = FileManager.default
            guard var fileArray = try? fileManager.contentsOfDirectory(atPath: logDoc) else { return }
            fileArray = fileArray.sorted { (file1, file2) -> Bool in
                return file1.compare(file2) == .orderedDescending
            }
            for logName in fileArray {
                if logName.hasSuffix("xlog") {
                    logFilesArray.append(logName)
                }
            }
            
            logUploodView.alpha = 0.1
            UIView.animate(withDuration: 0.5) {
                self.logUploodView.isHidden = false
                self.logUploodView.alpha = 1
            }
            logPickerView.reloadAllComponents()
        }
    }
    
    @objc private func logout(sender: UIButton) {
        let alertVC = UIAlertController.init(title: MainLocalize("App.PortalViewController.areyousureloginout"), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: MainLocalize("App.PortalViewController.cancel"), style: .cancel, handler: nil)
        let sureAction = UIAlertAction.init(title: MainLocalize("App.PortalViewController.determine"), style: .default) { (action) in
            if let userModel = ProfileManager.sharedManager().currentUserModel {
                HttpLogicRequest.userLogout(userId: userModel.userId, token: userModel.token ,success:nil ,failed:nil)
                
            }
            ProfileManager.sharedManager().removeLoginCache()
            AppUtils.shared.appDelegate.showLoginViewController()
            TUILogin.logout {
            } fail: { _, _ in
            }
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(sureAction)
        present(alertVC, animated: true, completion: nil)
    }
}

extension MainViewController {
    @objc func setupToast() {
        ToastManager.shared.position = .bottom
    }
    
    @objc func makeToast(message: String) {
        view.makeToast(message)
    }
}

extension MainViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return logFilesArray.count
    }
}

extension MainViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < logFilesArray.count {
            return logFilesArray[row]
        }
        return nil
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mainMenuItems[indexPath.row].selectHandle()
    }
}

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainMenuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = mainMenuItems[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.reuseIdentifier, for: indexPath) as! MainCollectionViewCell
        cell.config(model)
        return cell
    }
    
}

// MARK: - internationalization string
fileprivate extension String {
    static let titleText = MainLocalize("Demo.TRTC.Portal.Main.title")
}
