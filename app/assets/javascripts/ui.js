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
	else if(window.location.href.indexOf("scope=coowned") != -1){
		jQuery(".coowned").addClass("current");
	}
	else if(window.location.href.indexOf("scope=approved") != -1){
		jQuery(".approved").addClass("current");
	}
	else if(window.location.href.indexOf("scope=submitted") != -1){
		jQuery(".submitted").addClass("current");
	}
	else if(window.location.href.indexOf("scope=rejected") != -1){
		jQuery(".rejected").addClass("current");
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
	else if(window.location.href.indexOf("scope=resources_editor") != -1){
		jQuery(".resources_editor").addClass("current");
	}
	else if(window.location.href.indexOf("scope=template_editor") != -1){
		jQuery(".template_editor").addClass("current");
	}
	else if(window.location.href.indexOf("scope=inst_administrator") != -1){
		jQuery(".inst_administrator").addClass("current");
	}
	else if(window.location.href.indexOf("scope=inst_reviewer") != -1){
		jQuery(".inst_reviewer").addClass("current");
	}
	else if(window.location.href.indexOf("scope=dmp_administrator") != -1){
		jQuery(".dmp_administrator").addClass("current");
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
/* Required Fields */
jQuery(function requiredFields(){
	jQuery("input.required, select.required, textarea.required").each(function(){
			if(jQuery(this).val().length == 0){
				jQuery(this).removeClass("filled").addClass("blank");
			}
			if(jQuery(this).val().length !== 0){
				jQuery(this).removeClass("blank").addClass("filled");
			}
	});
});
jQuery(function(){
	jQuery("input.required, select.required, textarea.required").bind("blur", function(e){
		if(jQuery(this).val().length == 0){
			jQuery(this).removeClass("filled").addClass("blank");
		}
		else {
			jQuery(this).removeClass("blank").addClass("filled");
		}
	});
});
