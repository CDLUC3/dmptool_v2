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
	$('#add_comments_link').click(function() {
		$('#comment_dialog_form').dialog( {
			width: 800,
			height: 200,
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
			open: function()
			{
				$("#comment_dialog_form").dialog("open");
			},
      close: function() {
        $('#comment_dialog_form').dialog("close");
        $(this).find('form')[0].reset();
      }
		}).prev ().find (".ui-dialog-titlebar-close").show();
		return false
	});
});

$(function() {
	$("#cancel_action").bind("click",function() {
		$("#flash_notice").remove();
	});
})