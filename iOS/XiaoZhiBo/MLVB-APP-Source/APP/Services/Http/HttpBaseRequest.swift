//
//  HttpBaseRequest.swift
//  TRTCAPP_AppStore
//
//  Created by WesleyLei on 2021/8/3.
//

import Alamofire
import Foundation

/// 针对AF进行封装调用
class HttpBaseRequest {
    // 网络回调统一格式
    typealias HttpCompletionCallBack = (_ model: HttpJsonModel) -> Void
    // 网络请求统一调用方式
    // URLEncoding.default:form格式
    // JSONEncoding.default:json格式
    static func trtcRequest(_ convertible: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, completionHandler: HttpCompletionCallBack? = nil) {
        trtcRequest(convertible, method: method, parameters: parameters, encoding: URLEncoding.default, completionHandler: completionHandler)
    }

    static func trtcRequest(_ convertible: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding, completionHandler: HttpCompletionCallBack? = nil) {
        // 可以做参数的拦截与传参的添加
        AF.request(convertible, method: method, parameters: addBaseParametersData(parameters), encoding: encoding)
            .trtcResponseJSON { data in
                var result: HttpJsonModel = HttpJsonModel()
                result.errorMessage = LoginLocalize("Demo.TRTC.http.syserror")
                if let respData = data.data, respData.count > 0 {
                    let value = try? JSONSerialization.jsonObject(with: respData, options: .mutableLeaves)
                    #if DEBUG
                        debugPrint("http_result" + "\(String(describing: value))") // 输出网络返回数据
                    #else
                    #endif
                    if let res = value as? [String: Any] {
                        if let jsonMOdel = HttpJsonModel.json(res) {
                            result = jsonMOdel
                            if (result.errorCode == 203) || (result.errorCode == 204) {
                                UserOverdueLogicManager.sharedManager().userOverdueState = .loggedAndOverdue
                            }
                        }
                    }
                }
                // 请求完成回调
                completionHandler?(result)
            }
    }
    
    /// Cos文件上传
    /// - Parameters:
    ///   - url: URL请求地址
    ///   - data: 上传的文件Data
    ///   - mimeType: multipartFormData-mimeType
    ///   - name: multipartFormData-name
    ///   - fileName: multipartFormData-fileName
    ///   - headers: 请求Header
    ///   - completionHandler: 请求回调
    /// - Note: Alamofire upload 不支持参数设置，需要自己处理下请求地址
    static func trtcUpload(_ url: URLConvertible,
                           data: Data,
                           mimeType: String,
                           name: String = "file",
                           fileName: String? = nil,
                           headers: [String: String]? = nil,
                           completionHandler: HttpCompletionCallBack? = nil) {
        let result: HttpJsonModel = HttpJsonModel()
        let headerInfo: HTTPHeaders? = (headers != nil) ? HTTPHeaders(headers!) : nil
        guard var uploadRequest = try? URLRequest(url: url, method: .post, headers: headerInfo) else {
            result.errorMessage = "upload error: URLRequest generate error"
            completionHandler?(result)
            return
        }
        // 超时设置
        uploadRequest.timeoutInterval = 2*60
        AF.upload(multipartFormData: { formData in
            formData.append(data, withName: name, fileName: fileName, mimeType: mimeType)
        }, with: uploadRequest).response { response in
            // 上传成功时返回的 HTTP 状态码，可选200、201或204，默认为204。
            // 上传成功时重定向的目标 URL 地址，如果设置，那么在上传成功时将返回 HTTP 状态码为303（Redirect）
            if response.response?.statusCode == 200 || response.response?.statusCode == 303 || response.response?.statusCode == 204 {
                result.errorCode = 0
                result.errorMessage = "success"
            } else if let statusCode = response.response?.statusCode {
                result.errorCode = Int32(statusCode)
                result.errorMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            } else {
                result.errorCode = -1
                result.errorMessage = LoginLocalize("Demo.TRTC.http.syserror")
            }
            // 请求完成回调
            completionHandler?(result)
        }
    }
    
    private static func addBaseParametersData(_ parameters: Parameters? = nil) -> Parameters? {
        guard var resultParameters = parameters else {
            return nil
        }
        if let userId = ProfileManager.sharedManager().currentUserModel?.userId {
            if resultParameters["userId"] == nil {
                resultParameters["userId"] = userId
            }
        }
        if let token = ProfileManager.sharedManager().currentUserModel?.token {
            if resultParameters["token"] == nil {
                resultParameters["token"] = token
            }
        }
        if let apaasUserId = ProfileManager.sharedManager().currentUserModel?.apaasUserId {
            if (resultParameters["apaasUserId"] == nil) && (apaasUserId.byteLength() > 1) {
                resultParameters["apaasUserId"] = apaasUserId
            }
        }
        if resultParameters["appId"] == nil {
            resultParameters["appId"] = HttpLogicRequest.sdkAppId
        }
        return resultParameters
    }
}

// 为了调试方便，拦截打印了url和请求参数
extension DataRequest {
    @discardableResult
    public func trtcResponseJSON(completionHandler: @escaping (AFDataResponse<Any>) -> Void) -> Self {
        responseJSON { data in
            #if DEBUG
                debugPrint("url:\(String(describing: self.convertible.urlRequest))")
                debugPrint("trtcParameters:\(String(describing: self.convertible.trtcParameters()))")
            #else
            #endif
            completionHandler(data)
        }
    }
}

// 为了调试方便，获取请求参数
extension URLRequestConvertible {
    func trtcParameters() -> Parameters? {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.label == "parameters" {
                return (child.value as? Parameters)
            }
        }
        return nil
    }
}
