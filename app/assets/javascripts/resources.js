// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
	$("#text_details").hide();
	$("#resource_text").hide();
	$(document).on("ready", showHideDetails());
	$("#resource_resource_type").bind('change', function(){
		showHideDetails()
	});
		function showHideDetails() {
			var type = $("#resource_resource_type").val();
			if (type == "actionable_url")
			{

				$("#value").show();
				$("#resource_value").show();

				$("#label").show();
				$("#resource_label").show();
				
				$("#text").hide();
				$("#resource_text").hide();

			}

			else {

				$("#label").show();
				$("#resource_label").show();

				$("#text").show();
				$("#resource_text").show();

				$("#value").hide();
				$("#resource_value").hide();				
				
			}
		}
});