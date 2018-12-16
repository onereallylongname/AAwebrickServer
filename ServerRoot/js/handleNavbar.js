window.onscroll = function() {myFunction()};
var navbar = document.getElementById("navbar");
console.log(navbar);
var sticky = navbar.offsetTop;

function myFunction() {
  if (window.pageYOffset >= sticky) {
    navbar.classList.add("sticky")
  } else {
    navbar.classList.remove("sticky");
  }
}
// Add active class to the current button (highlight
var btns = navbar.getElementsByClassName("navbaritem");
console.log(btns);
for (var i = 0; i < btns.length; i++) {
  console.log(btns[i]);
  btns[i].addEventListener("click", function() {
    var current = document.getElementsByClassName("active");
    current[0].className = current[0].className.replace(" active", "");
    this.className += " active";
  });
}
