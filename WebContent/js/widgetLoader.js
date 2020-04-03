
$(document).ready(function () {
	$(document.body).append('<div id="spinner-front"><img src="images/Wedges-3s-200px.gif"/></div><div id="spinner-back"></div>');
	
	
	
	//$(document.body).append('<div id="ajaxloader" style<img id="ajaxloader-img" src="../images/ajax-loader.gif" alt="Wait" style="vertical-align: middle; width: 90px; height:90px" />');
	//$("#ajaxloader").css({position: 'absolute', top: (($(window).height() / 2) - ($("#ajaxloader").width() / 2)) + "px", left: ($(window).width() - $("#ajaxloader").width()) / 2 + "px", zIndex: 100000});	
});
	
function showLoader () {
	  document.getElementById("spinner-front").classList.add("show");
	  document.getElementById("spinner-back").classList.add("show");
};

function hideLoader () {
  document.getElementById("spinner-front").classList.remove("show");
  document.getElementById("spinner-back").classList.remove("show");
};
