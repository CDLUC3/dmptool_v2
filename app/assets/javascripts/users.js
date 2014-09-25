

// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {

	$('#roles_dialog_form').hide();
	$('#edit_user_roles_view').click(function() {
		$('#roles_dialog_form').dialog( {
			width: 600,
			height: 200,
			title: "Edit Roles for the User",
			buttons: {
				"Cancel" : function() {
					$("#roles_dialog_form").dialog("close");
				},
			 "Add"	: function() {
					$("#roles_dialog_form").dialog
				}
			}
		}).prev().find(".ui-dialog-titlebar-close").hide(); // To hide the standard close button
	return false
	});

});


// //automatically checks Institutional reviewer role when Institutional Administrator role gets checked
$(function() {
	$('#5').change(function(){
		if ($('#5').is(':checked')) { 
			$('#4').prop('checked', true);
		}
	});
});




//orcid id change link
$(function() {
	$("#orcid_input_box").hide();
	$('#change_orcid').click(function(event){
			event.preventDefault();
	    $('#orcid_input_box').toggle();
	});
});


// alert message if DMP Admin remove his own DMP admin role
$(function() {
	$('#current_dmp_admin_with_alert').click(function(){
		if (!$('#1').is(':checked')) { 

			//showConfirmDialog

			//if ($('#current_admin_with_alert').confirm( "Do you really want to remove yourself from the DMP Administrator role? You will lose all administrative permissions.")){
			if (confirm( "Do you really want to remove yourself from the DMP Administrator role? You will lose all administrative permissions.")){
				return true;
			}
			else {
				return false;
			};
		};
	});
});


//adds effects to token generator
// $(function() {
// 	$("#fade_slow").fadeOut( "slow" );
// });


















