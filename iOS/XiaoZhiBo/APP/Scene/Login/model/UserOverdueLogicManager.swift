//
//  UserOverdueLogicManager.swift
//  TRTCAPP_AppStore
//
//  Created by WesleyLei on 2021/7/28.
//

import Foundation
import Alamofire
import TUICore

//用户状态枚举
@objc enum UserOverdueState : Int {
    case notLogin = 0//用户没有登录
    case alreadyLogged = 1//用户已经登录
    case loggedAndOverdue = 2//登录了token已经失效或者被踢出，这种情况需要强制引导登录：清理ui，清理资源
}

//MARK: 用户登录状态管理
public class UserOverdueLogicManager: NSObject {
    private static let staticInstance: UserOverdueLogicManager = UserOverdueLogicManager.init()
    static func sharedManager() -> UserOverdueLogicManager { staticInstance }
    private override init(){
        super.init()
        viewModel = UserOverdueViewModel()
        self.addObserver(viewModel, forKeyPath: "_userOverdueState", options: [.old, .new], context: nil)
    }

    public var viewModel: UserOverdueViewModel!
    //set get 方法
    @objc dynamic private var _userOverdueState: UserOverdueState = .notLogin
    weak var nowAlertController: UIAlertController?
    var userOverdueState: UserOverdueState{
        set{
            switch newValue {
                case .notLogin:
                    if _userOverdueState == .alreadyLogged {//退出登录
                        _userOverdueState = newValue
                    }
                    break
                case .alreadyLogged://重新登录或者已经登录
                    _userOverdueState = newValue
                    break
                case .loggedAndOverdue://登录了token已经失效或者被踢出
                    _userOverdueState = newValue
                    break
            }
        }
        get{
            return _userOverdueState
        }
    }
}
//MARK: token失效
public class UserOverdueViewModel: NSObject {
    //用户状态变更监听
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "_userOverdueState" {
            if UserOverdueLogicManager.sharedManager().userOverdueState == .loggedAndOverdue {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()){
                    self.showOverdueAlertView()
                }
            }
        }
    }
    //强制登出弹窗
    func showOverdueAlertView() {
        if UserOverdueLogicManager.sharedManager().nowAlertController != nil {
            return
        }
        let alertController = UIAlertController.init(title: LoginLocalize("Demo.TRTC.LiveRoom.prompt"), message: LoginLocalize("Demo.TRTC.Home.useroverduemessage"), preferredStyle: .alert)
        let sureAction = UIAlertAction.init(title: LoginLocalize("LoginNetwork.AppUtils.determine"), style: .default) {(action) in
            ProfileManager.sharedManager().removeLoginCache()
            AppUtils.shared.appDelegate.showLoginViewController()
            TUILogin.logout {
            } fail: { _, _ in
            }
        }
        alertController.addAction(sureAction)
        if let keyWindow = AppUtils.getCurrentWindow(), let rootViewController = keyWindow.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
        UserOverdueLogicManager.sharedManager().nowAlertController = alertController;
    }
}
