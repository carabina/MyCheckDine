function receivedTableCode(json){
var obj = JSON.parse(json)
var body = obj["body"]
  var code = body["code"]
   document.getElementById('codeLabel').innerHTML = code
}
