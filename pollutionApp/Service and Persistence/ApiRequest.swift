import Alamofire

class ApiRequest {
    
    func getRequest(requestUrl: String,personalKey: String, completion: @escaping (_ result: Result<Data>)->Void)   {
        
        Alamofire.request("\(requestUrl)key=\(personalKey)", method: .get, parameters:nil).responseData { response in
            print(response)
            
            
            if let error = response.error {
                return completion(.failure(error))
            }
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("example success")
                default:
                    print("error with response status: \(status)")
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "error with response status: \(status)"])
                    return completion(.failure(error ))
                }
            }
            
            
            
            if let data = response.data {
                return completion(.success(data))
            }
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "unexpected error"])
            return completion(.failure(error ))
        }
    }
}
