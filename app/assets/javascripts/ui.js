/* Add class according to alphabetical view of tabular data */
jQuery(function(){
	if(window.location.href.indexOf("e=z&s=a") != -1){
		jQuery(".viewA-Z").addClass("current");
	}
	else if(window.location.href.indexOf("e=f&s=a") != -1){
		jQuery(".viewA-F").addClass("current");
	}
	else if(window.location.href.indexOf("e=l&s=g") != -1){
		jQuery(".viewG-L").addClass("current");
	}
	else if(window.location.href.indexOf("e=s&s=m") != -1){
		jQuery(".viewM-S").addClass("current");
	}
	else if(window.location.href.indexOf("e=z&s=t") != -1){
		jQuery(".viewT-Z").addClass("current");
	}
	else {
		jQuery(".viewA-Z").addClass("current");
	}
});
/* Add class according to categorical view of tabular data */	
jQuery(function(){
	if(window.location.href.indexOf("scope=all_limited") != -1){
		jQuery(".all_limited").addClass("current");
	}
	else if(window.location.href.indexOf("scope=active") != -1){
		jQuery(".active").addClass("current");
	}
	else if(window.location.href.indexOf("scope=inactive") != -1){
		jQuery(".inactive").addClass("current");
	}
	else if(window.location.href.indexOf("scope=institutional") != -1){
		jQuery(".institutional").addClass("current");
	}
	else if(window.location.href.indexOf("scope=public") != -1){
		jQuery(".public").addClass("current");
	}
	else {
		jQuery(".all_limited").addClass("current");
	}
});
/* Toggle Tabular data links */
jQuery(function(){
	jQuery(".toggle-links").hover(
		function(){jQuery(this).parent().find(".template-links").css("visibility", "visible");},
		function(){jQuery(this).parent().find(".template-links").css("visibility", "hidden");}
	);
});
