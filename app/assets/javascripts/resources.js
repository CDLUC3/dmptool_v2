// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
	$("#text_details").hide();
	$("#resource_text").hide();
	$("#resource_resource_type").change(function(){
		var type = $(this).val();
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
	});
});