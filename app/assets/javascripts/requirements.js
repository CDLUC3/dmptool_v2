// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function(){
	$("fieldset.requirement_type").hide();
	$("#requirement_requirement_type").change(function(){
		if($("#requirement_requirement_type").val() == "enum") {
			$("fieldset.requirement_type").show();
		} else {
			$("fieldset.requirement_type").hide();
		}
	});
});