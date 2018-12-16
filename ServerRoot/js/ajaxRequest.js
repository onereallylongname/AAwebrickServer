function ajaxJsonRequest(processResponse, path, method = "GET", sendBody = '') {
  if(!path){
    console.log('Invalid request detected!');
    return
  }
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var jsonObj = JSON.parse(this.responseText);
     processResponse(jsonObj);//this.responseText;
   }else if (this.readyState == 4){
     console.log(this);
   }
  };
  //xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  //xhttp.setRequestHeader("Connection", "close");
  xhttp.open(method, path, true);
  xhttp.send(sendBody);
}
