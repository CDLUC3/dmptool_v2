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
				$("#text_details").hide();
				$("#resource_text").hide();
				$("#value_details").show();
				$("#resource_label").show();
				$("#resource_value").show();
			}
			else {
				$("#text_details").show();
				$("#resource_text").show();
				$("#value_details").hide();
				$("#resource_label").hide();
				$("#resource_value").hide();
			}
		}
});