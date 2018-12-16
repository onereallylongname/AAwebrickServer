//   R0.50.62.3

let release = '';
let getButtonName = '';
let loginErrorDispaly = false;
function updateNameRelease(inputText) {
  release = inputText.value;
}

function getTimeNowString(){
  let currentdate = new Date();
  let datetime = currentdate.getDate() + "/"
                + (currentdate.getMonth()+1)  + "/"
                + currentdate.getFullYear() + " "
                + currentdate.getHours() + ":"
                + currentdate.getMinutes() + ":"
                + currentdate.getSeconds();
  return datetime;
}

function setDivText(divValue, divId){
  let div = document.getElementById(divId);
  div.innerHTML = divValue
}

function updateLastUpdateText(divId){
  setDivText(release + " - last update : " + getTimeNowString() , divId);
}

function getId(){
  let url_string = window.location.href
  let url = new URL(url_string);
  let id= url.searchParams.get("id");
  return id
}

function logout(){
  var r = confirm("Do you want to end your session?");
    if (r == true) {
      let id = getId();
      let url = "/services/rest/logout?id="+id;
      ajaxJsonRequest(redirectToLogin, url);
    } else {
      console.log('Cancel.');
    }
}

function redirectToLogin(json){
  console.log(json);
  window.location.replace("/");
}

function makeJsonUlrRequest(divId){
  let id = getId();
  if(!release){
      alert('There must be a value for the Release!');
      document.getElementById(getButtonName).disabled = false;
      hideShowLoader('loader', false);
      return null;
  }
  switch(divId) {
    case 'GetJira':
      return "/services/rest/jira/get/release?id="+id+'&release='+release
      break;
    case 'confluenceText':
        return "/services/rest/jira/get/info/confluence?id="+id
        break;
    case 'jiraText':
        return "/services/rest/jira/get/info/jira?id="+id
        break;
    case 'deliverablesText':
      //  return "/services/rest/jira/get/info/deliverables?id="+id+"&useWarn=N"
      return "/services/rest/jira/get/info/deliverables?id="+id
        break;
    case 'releaseText':
        return "/services/rest/jira/get/info/release?id="+id
        break;
    case 'warnText':
        return "/services/rest/jira/get/info/warning?id="+id
        break;
    default:
        return null;
    }

}

function displayJsonJira (json){
  if (json.hasOwnProperty('error') && !loginErrorDispaly){
    loginErrorDispaly = true;
    console.log(json);
    alert('Login failed!\n'+json.description);
    if(json.description.includes("Try login"))
      window.location.replace("/");
  }else{
    let keysSet = Object.keys(json);
    console.log(json);
    console.log(keysSet);
    if(keysSet.includes('confluenceText')){
      makeConfJiraText(json, 'confluenceText');
    }else if(keysSet.includes('jiraText')){
      makeConfJiraText(json, 'jiraText');
    }else if(keysSet.includes('releaseText')){
      makeReleaseText(json, 'releaseText');
    }else if(keysSet.includes('deliverablesText')){
      makeDeliverablesText(json, 'deliverablesText');
    }else if(keysSet.includes('warnText')){
      let text = makeWarningText(json);
      setDivText(text, 'warnText');
    }else{
      updateLastUpdateText('TOPupdate');
      displayJson(json);
    }
    loginErrorDispaly = false;
  }
}

function displayJson(json){
  console.log(JSON.stringify(json, null, 2));
}

function getJira(btnName){
  console.log('Clicked');
  hideShowLoader('loader', true);
  getButtonName = btnName;
  document.getElementById(getButtonName).disabled = true;
  ajaxJsonRequest(receiveJira, makeJsonUlrRequest('GetJira'))
}

function receiveJira(json){
  displayJsonJira(json);
  if(!loginErrorDispaly){
    ajaxJsonRequest(displayJsonJira, makeJsonUlrRequest('warnText'));
    ajaxJsonRequest(displayJsonJira, makeJsonUlrRequest('confluenceText'));
    ajaxJsonRequest(displayJsonJira, makeJsonUlrRequest('jiraText'));
    ajaxJsonRequest(displayJsonJira, makeJsonUlrRequest('deliverablesText'));
    ajaxJsonRequest(displayJsonJira, makeJsonUlrRequest('releaseText'));
  }
  document.getElementById(getButtonName).disabled = false;
  hideShowLoader('loader', false);
}

function setDivText(divValue, divId){
  let div = document.getElementById(divId);
  div.innerHTML = divValue;
}

function makeConfJiraText(json, updatedDivId){
  let htmlText = '';
  Object.keys(json[updatedDivId]).forEach(function(key,index) {

    let text = json[updatedDivId][key].replace(/\\n/g, "<br>");
    if(!text)
      text = "N/A<br>"
    htmlText += "<br><b>"+key+"</b><br>" + text
  });
  setDivText(htmlText, updatedDivId);
//  if(!!json.warning){
//    document.getElementById('warnText').display = "block";
//  }
}

function makeReleaseText(json, updatedDivId){
  let list = json.releaseText.list;
  htmlText = '';
  Object.keys(list).forEach(function(key,index) {
    htmlText += "<div class=\"mycontainer\"><h4><a class=\"goto\" id=\""+key+"\"></a><a href=\"" + list[key].url + "\" target=\"_blank\">" + key + "</a> - " + list[key].summary + "</h4><b>Status:</b> " + list[key].status + "<br><b>Assignee:</b> " + list[key].assignee + "</div><br>";
  });
  setDivText(htmlText, updatedDivId);
}

function makeDeliverablesText(json, updatedDivId){
  let text = json.deliverablesText;
  let htmlText = '<table style="width:100%">';
  console.log(text);
  Object.keys(text).forEach(function(key,index) {
    let arr = text[key]
    if(arr['artifacts']){
      htmlText += "<tr><td></td><th>" + key + ' (' + arr['artifacts'].length.toString() + ")</th><td></td><tr>";
      htmlText += makeDeliverablesLines(arr['artifacts'], arr['issueKeys'], 0, 0, key);
    }
  });
  htmlText += '</table>';
  setDivText(htmlText, updatedDivId);
}

function makeDeliverablesLines(arr, issueKeys, cN, indent, name){
  console.log(name);
  let htmlText = '';
  let newCN = cN;
  let currId = "";
  if(arr instanceof Array){
    arr.forEach(function(element, index){
      currId = name + newCN.toString();
      console.log('in array');
      console.log(currId);
    console.log(element);
      if(typeof(element) == 'string'){
        htmlText += "<tr><td><div type=\"button\" class=\"copyCellButton\" onclick=\"selectElementContents('"+currId+"');\"><i class=\"fa fa-files-o\"></i></div></td><td><span style=\"padding-left: " + indent.toString() + "px;\" id=\""+currId+"\">" + element + "</span></td>"
        if(issueKeys[index] === undefined ){
          htmlText += "</tr>"
        }else{
          htmlText += "<td><a href=\"#"+issueKeys[index]+"\">"+issueKeys[index]+"</a></td></tr>"
        }
      }else{
        htmlText += makeDeliverablesLines(element, issueKeys, newCN, indent+5, currId);
      }
      newCN += 1;
    });
  }else{
    Object.keys(arr).forEach(function(element, index){
      indent += 10
      currId = name + newCN.toString();
      console.log('in Object');
      console.log(currId);
      console.log(element);
      htmlText += "<tr><td></td><td><span style=\"padding-left: " + indent.toString() + "px;\" id=\""+currId+"\">" + element + "</span></td>"
      if(issueKeys[index] === undefined ){
        htmlText += "</tr>"
      }else{
        htmlText += "<td><a href=\"#"+issueKeys[index]+"\">"+issueKeys[index]+"</a></td></tr>"
      }
      htmlText += makeDeliverablesLines(arr[element], issueKeys, newCN, indent+10, currId);

      newCN += 1;
    });
  }
  return htmlText;
}

function makeWarningText(json){
  let htmlText = '';
  let okText = '';
  let warnText = '';
  Object.keys(json.warnText).forEach(function(user,index) {
    let userText = json.warnText[user];
    if(user != 'keys'){
      if(!!userText)  {
        warnText += "<h5>"+ user +"</h5>" +  userText.replace(/\\n/g, "<br>");
      }else{
        okText += "<h5>"+ user +"</h5>";
      }
    }
  });
  if(!!warnText)
    htmlText += "<h4 style=\"color:red;\">Warning</h4>" + warnText ;
  if(!!okText)
    htmlText += "<h4 style=\"color:green;\">All Ok</h4>" + okText;
  return htmlText;
}

function selectElementContents(elName) {
console.log(elName)
 let el = document.getElementById(elName);
 console.log(el)
 copyToClipboard(el.innerText);
 el.style.backgroundColor =  "grey"
}

function copyToClipboard(text) {
 if (window.clipboardData && window.clipboardData.setData) {
     // IE specific code path to prevent textarea being shown while dialog is visible.
     return clipboardData.setData("Text", text);

 } else if (document.queryCommandSupported && document.queryCommandSupported("copy")) {
   var textarea = document.createElement("textarea");
   textarea.textContent = text;
   textarea.style.position = "fixed";  // Prevent scrolling to bottom of page in MS Edge.
   document.body.appendChild(textarea);
   textarea.select();
   try {
       return document.execCommand("copy");  // Security exception may be thrown by some browsers.
   } catch (ex) {
       console.warn("Copy to clipboard failed.", ex);
       return false;
   } finally {
       document.body.removeChild(textarea);
   }
 }

}
function hideShow(btn,divName) {
    var x = document.getElementById(divName);
    if (x.style.display === "none") {
        x.style.display = "block";
        btn.innerHTML = "Hide"
    } else {
        x.style.display = "none";
        btn.style.opacity = 0.9;
        btn.innerHTML = "Show"
    }
}

function hideShowLoader(loader, show){
	 var x = document.getElementById(loader);
    if (show) {
        x.style.display = "block";
    } else {
        x.style.display = "none";

    }
}
