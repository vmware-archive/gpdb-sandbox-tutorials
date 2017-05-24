$(document).ready(function(){
	$('nav a').each(function (){
	  if (document.location.pathname == $(this).attr('href')) {
	    $(this).addClass('active');
	  }
	});
});