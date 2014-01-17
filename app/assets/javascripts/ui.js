jQuery(function(){
	if(window.location.href.indexOf("scope=all_limited") != -1){
		jQuery(".all_limited").parent().addClass("current");
	}
	else if(window.location.href.indexOf("scope=active") != -1){
		jQuery(".active").parent().addClass("current");
	}
	else if(window.location.href.indexOf("scope=inactive") != -1){
		jQuery(".inactive").parent().addClass("current");
	}
	else if(window.location.href.indexOf("scope=institutional") != -1){
		jQuery(".institutional").parent().addClass("current");
	}
	else if(window.location.href.indexOf("scope=public") != -1){
		jQuery(".public").parent().addClass("current");
	}
	else {
		jQuery(".all_limited").parent().addClass("current");
	}
});

jQuery(function(){
	jQuery(".toggle-links").hover(
		function(){jQuery(this).parent().find(".template-links").css("visibility", "visible");},
		function(){jQuery(this).parent().find(".template-links").css("visibility", "hidden");}
	);
});