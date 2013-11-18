// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$(function() {
	$("fieldset.requirement_type").hide();
	$(document).on("ready", showHideEnum());
	$("#requirement_requirement_type").bind('change', function(){
		showHideEnum();
	});

	function showHideEnum() {
		if($("#requirement_requirement_type").val() == "enum") {
			$("fieldset.requirement_type").show();
		} else {
			$("fieldset.requirement_type").hide();
		}
	}
});


// from http://nack.co/get-url-parameters-using-jquery/ to check parameters.
$.urlParam = function(name){
    var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (!results) { return ''; }
    return results[1] || 0;
};
$(document).ready(function() {
	if($.urlParam('node_type') == 'group') {
		$("#requirement_obligation_optional").prop('checked', false);
  	$("#requirement_text_full, #requirement_requirement_type, #requirement_obligation_mandatory, #requirement_obligation_mandatory_applicable, #requirement_obligation_recommended, #requirement_obligation_optional").prop("disabled", true);
  	$("#if_group").prop('checked', true);
 	}
});