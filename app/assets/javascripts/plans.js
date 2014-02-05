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
			width: 650,
			height: 380,
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

$(document).ready(function() {
  return $("##comment_dialog_form").on("ajax:success", function(e, data, status, xhr) {
    return $("#comment_dialog_form").append(xhr.responseText);
  }).bind("ajax:error", function(e, xhr, status, error) {
    return $("#comment_dialog_form").append("<p>ERROR</p>");
  });
});