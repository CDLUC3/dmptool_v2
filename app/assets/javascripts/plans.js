// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
	$("#submission_deadline.datepicker").datepicker( {
		showOn: 'button',
		buttonImage: "http://jqueryui.com/resources/demos/datepicker/images/calendar.gif",
		dateFormat: "mm/dd/yy",
		changeMonth: true,
		changeYear: true,
		numberOfMonths: 2
	});
});

$(function() {
	$('#comment_dialog_form').hide();
	$('#add_comments_link').click(function(event) {
		event.preventDefault();
		$('#comment_dialog_form').dialog( {
			width: 600,
			height: 300,
			modal: true,
			closeOnEscape: true,
			draggable: true,
			resizable: false,
			title: "Add New Comments",
			show: {
				effect: "blind",
				duration: 1000
			},
			hide: {
				effect: "toggle",
				duration: 1000
			},
      "Submit": function()
        {
        	$("#comment_dialog_form").submit();
        },
        "Cancel" : function()
        {
        	$("#comment_dialog_form").dialog("close");
        }
		});
		return false
	});
});

$(function() {
	$("#cancel_action").bind("click",function() {
		$("#flash_notice").remove();
	});
})

$(function() {
	$("#reviewer_comments").hide();
	$("#view_reviewer_comments").click(function(event){
		event.preventDefault();
		$("#reviewer_comments").show();
	});
});

$(function() {
	$("#hide_reviewer_comments").click(function(event){
		event.preventDefault();
		$("#reviewer_comments").hide();
	});
});

$(function() {
	$("#owner_comments").hide();
	$("#view_owner_comments").click(function(event){
		event.preventDefault();
		$("#owner_comments").show();
	});
});

$(function() {
	$("#hide_owner_comments").click(function(event){
		event.preventDefault();
		$("#owner_comments").hide();
	});
});