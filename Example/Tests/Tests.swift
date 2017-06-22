
// https://github.com/Quick/Quick

import Quick
import Nimble
import MyCheckDine
import MyCheckCore
class BasicFlowTest: QuickSpec {
  
  let DefaultTimeoutLengthInNanoSeconds = Int64(Double(NSEC_PER_SEC) * 13.0)
  
  final let restaurantId = "2"
  final let hotelId = "1"
  final let updateExpectedValues = [2 ,5]
  var updatedCount = 0
  //called whenever a SDK function fails
  var fail : ((NSError) -> Void) = { error in
    print(error)
    expect("fail") == "not"
    
  }
  
  
  //The main function that runs the test
  override func spec() {
    describe("testing basic flow") {
      
      it("can perform all server calls") {
        
        expect(Session.shared.isLoggedIn()) == false // user not logged in
        
        waitUntil(timeout:6000.0) { done in
          Session.shared.configure("pk_fXACc6bLgs3zECbwSZyaXl7NrIa9P", environment: .test)
          sleep(2)
          
          //testing login
          Session.shared.login("eyJpdiI6IlN3cFBYM2pteUN0SFBFU082aWI0Rmc9PSIsInZhbHVlIjoia1BOejUxbVByUjZDNk1oSzBJM1lteWpvVndyRyt5SHVvbWp5VmRIRGlPaVNQbGxmV0FFNE91RGtVVSttd2h2YyIsIm1hYyI6ImMzZjUxZTNmZGYwMDJmODY4ZmFlYWY5NWNhM2RkZWZkYWVlODg1YWRkOWNiOTBhODMyODE4MjdhMjdhZTVmM2MifQ==" , success: {
            
            expect(Session.shared.isLoggedIn()) == true // user logged in
            
            
            //opening a table
            Dine.shared.generateCode(hotelId: self.hotelId , restaurantId: self.restaurantId, success: {
              code in
              expect(code.characters.count) == 4 // user not logged in
                 let _ = self.openTabe(code: code)
                  let _ = self.addItemsToOpenTable(code: code, BID: self.restaurantId)
              Dine.shared.poller.delegate = self

              Dine.shared.poller.startPolling()
              sleep(2)
              
              Dine.shared.getOrder(order: nil ,success: { order in
                let count = self.updatedCount
                //  expect(MyCheck.shared.poller.order!.items.count ).to( equal( self.updateExpectedValues[self.updatedCount - 1]))//checking that the amount of items reorderd is good
                Dine.shared.reorderItems(items: [(3, order.items.last!)], success: {
                     let _ = self.flushPendingItemsInPOS(code: code, BID: self.restaurantId)
                    //sleep(7)
                    //  expect(count ).to( equal( 1 + self.updatedCount))//checking that the amount of items reorderd is good

                    //  expect(MyCheck.shared.poller.order!.items.count ).to( equal( self.updateExpectedValues[self.updatedCount]))//checking that the amount of items reorderd is good

                      self.closeTable(code: code, BID: self.restaurantId)
done()
                }, fail: self.fail)

              }, fail: self.fail)
            }, fail: self.fail)
            
            
          }, fail: self.fail)
        }
      }
    }
  }
  
  
  
  
  //opens a table from a fake POS with the code the SDK generated
  func openTabe(code : String) -> NSInteger{
    var toReturn = -1
    //creating a semaphore so the call will be done synchroniously
    let semaphore = DispatchSemaphore(value: 0)
    
    let URL = NSURL(string:"https://test.mycheckapp.com/api/table/act/open?BID=\(restaurantId)&ClientCode=\(code)")!
    
    
    let session = URLSession.shared
    let task = session.dataTask(with: URL as URL) { data, response, error in
      XCTAssertNotNil(data, "data should not be nil")
      XCTAssertNil(error, "error should be nil")
      
      if let HTTPResponse = response as? HTTPURLResponse,
        let responseURL = HTTPResponse.url
      {
        XCTAssertEqual(responseURL.absoluteString, URL.absoluteString, "HTTP response URL should be equal to original URL")
        XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
        let _ : NSDictionary? = self.convertDataToJSON(data: data! as NSData)
        //                toReturn = json?.objectForKey("ErrorCode")?.integerValue ?? -2
        let datastring = NSString(data:data!, encoding:String.Encoding.utf8.rawValue) as! String
        //  let success : NSNumber = json?.objectForKey("Success") as! NSNumber
        toReturn = datastring.contains("Success\":true")  ? 0 : -3
        
        
      } else {
        XCTFail("Response was not NSHTTPURLResponse")
      }
      
      semaphore.signal() // 2
    }
    
    task.resume()
    
    //        let timeout = dispatch_time_t() + UInt64(DefaultTimeoutLengthInNanoSeconds*2)// twice cause we are calling 2 apis
    //        let dTime = DispatchTime(uptimeNanoseconds: timeout)
    //        if semaphore.wait(timeout: dTime) == DispatchTimeoutResult.timedOut {
    //            XCTFail("\(URL.description) timed out")
    //        }
    if toReturn == 0 {
        // let _ = self.addItemsToOpenTable(code: code, BID: restaurantId)
      
    }
    return toReturn ;    }
  
  
  //closes a table from the POS side
  func closeTable(code: String, BID: String) -> Void {
    let semaphore = DispatchSemaphore(value: 0)
    
    let URL = NSURL(string:"https://test.mycheckapp.com/api/table/act/close?BID=\(BID)&ClientCode=\(code)")!//"https://test.mycheckapp.com/api/table/act/open?BID=\(BID)&ClientCode=\(code)")!
    
    
    let session = URLSession.shared
    let task = session.dataTask(with: URL as URL) { data, response, error in
      XCTAssertNotNil(data, "data should not be nil")
      XCTAssertNil(error, "error should be nil")
      
      if let HTTPResponse = response as? HTTPURLResponse,
        let responseURL = HTTPResponse.url
        //MIMEType = HTTPResponse.MIMEType
      {
        XCTAssertEqual(responseURL.absoluteString, URL.absoluteString, "HTTP response URL should be equal to original URL")
        XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
        let json: NSDictionary? = self.convertDataToJSON(data: data! as NSData)
        //toReturn = json?.objectForKey("ErrorCode")?.integerValue ?? -2
        print(json ?? "bad JSON")
      } else {
        XCTFail("Response was not NSHTTPURLResponse")
      }
      
      semaphore.signal() // 2
    }
    
    task.resume()
    //        let timeout = dispatch_time_t() + UInt64(DefaultTimeoutLengthInNanoSeconds)// twice cause we are calling 2 apis
    //        let dTime = DispatchTime(uptimeNanoseconds: timeout)
    //
    //        if semaphore.wait(timeout: dTime) == DispatchTimeoutResult.timedOut { // 3
    //            XCTFail("\(URL.description) timed out")
    //        }
  }
  
  //adds items to a table if one is open from the POS side
  func addItemsToOpenTable(code: String, BID: String) -> NSInteger{
    var toReturn = -1
    //creating a semaphore so the call will be done synchroniously
    let semaphore = DispatchSemaphore(value: 0)
    let urlStr = "https://test.mycheckapp.com/api/sync?BID=\(BID)&ClientCode=\(code)&Discount=0.00&Service=0&Payments=[]&Items=[{\"Name\":\"Tea\",\"Cost\":3.6,\"Quantity\":2,\"SerialID\":9951,\"Remarks\":\"\",\"Toppings\":\"\",\"Price\":3.6}]" as NSString
    let str = urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    let URL = NSURL(string:str!)!
    
    
    let session = URLSession.shared
    let task = session.dataTask(with: URL as URL) { data, response, error in
      XCTAssertNotNil(data, "data should not be nil")
      XCTAssertNil(error, "error should be nil")
      
      if let HTTPResponse = response as? HTTPURLResponse,
        let responseURL = HTTPResponse.url
      {
        XCTAssertEqual(responseURL.absoluteString, URL.absoluteString, "HTTP response URL should be equal to original URL")
        XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
        let json: NSDictionary? = self.convertDataToJSON(data: data! as NSData)
        let datastring = NSString(data:data!, encoding:String.Encoding.utf8.rawValue)
        //  let success : NSNumber = json?.objectForKey("Success") as! NSNumber
        toReturn = (datastring?.contains("Success\":true"))!  ? 0 : -3
        print(json ?? "Bad JSON")
      } else {
        XCTFail("Response was not NSHTTPURLResponse")
      }
      
      semaphore.signal() // 2
    }
    
    task.resume()
    //        let timeout = dispatch_time_t() + UInt64(DefaultTimeoutLengthInNanoSeconds)// twice cause we are calling 2 apis
    //        let dTime = DispatchTime(uptimeNanoseconds: timeout)
    
    //        if semaphore.wait(timeout: dTime) == DispatchTimeoutResult.timedOut { // 3
    //            XCTFail("\(URL.description) timed out")
    //        }
    return toReturn ;
    
    
  }
  
    
    
    
    //adds items to a table if one is open from the POS side
    func flushPendingItemsInPOS(code: String, BID: String) -> NSInteger{
        var toReturn = -1
        //creating a semaphore so the call will be done synchroniously
        let semaphore = DispatchSemaphore(value: 0)
        let urlStr = "https://test.mycheckapp.com/api/setAllPollPendingsAsDone?BID=\(BID)&ClientCode=\(code)&SecurityWord=\"itsnotwhatyouthinksheismysister\"" as NSString
        let str = urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let URL = NSURL(string:str!)!
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: URL as URL) { data, response, error in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            
            if let HTTPResponse = response as? HTTPURLResponse,
                let responseURL = HTTPResponse.url
            {
                XCTAssertEqual(responseURL.absoluteString, URL.absoluteString, "HTTP response URL should be equal to original URL")
                XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
                let json: NSDictionary? = self.convertDataToJSON(data: data! as NSData)
                let datastring = NSString(data:data!, encoding:String.Encoding.utf8.rawValue)
                //  let success : NSNumber = json?.objectForKey("Success") as! NSNumber
                toReturn = (datastring?.contains("Success\":true"))!  ? 0 : -3
                print(json ?? "Bad JSON")
            } else {
                XCTFail("Response was not NSHTTPURLResponse")
            }
            
            semaphore.signal() // 2
        }
        
        task.resume()
        //        let timeout = dispatch_time_t() + UInt64(DefaultTimeoutLengthInNanoSeconds)// twice cause we are calling 2 apis
        //        let dTime = DispatchTime(uptimeNanoseconds: timeout)
        
        //        if semaphore.wait(timeout: dTime) == DispatchTimeoutResult.timedOut { // 3
        //            XCTFail("\(URL.description) timed out")
        //        }
        return toReturn ;
        
        
    }

    
  func convertDataToJSON(data: NSData) -> NSDictionary? {
    do {
      return try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String:AnyObject] as NSDictionary?
    } catch let error as NSError {
      print(error)
    }
    
    return nil
  }
  
}

extension BasicFlowTest : OrderPollerDelegate{
  
  func orderUpdated(order:Order){
    updatedCount += 1
    //expect(self.updatedCount).to( beLessThan( updateExpectedValues.count))//checking that this isnt called more than expected

    //expect(order.items.count ).to( equal( updateExpectedValues[updatedCount]))//checking that the amount of items reorderd is good
  }
  
 
  func failingToReceiveUpdates(lastReceivedError: Error , failCount:Int){
  
  }
}
