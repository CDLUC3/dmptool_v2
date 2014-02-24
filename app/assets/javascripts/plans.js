// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
	$("#submission_deadline.datepicker").datepicker( {
		showOn: 'button',
		buttonImage: "http://jqueryui.com/resources/demos/datepicker/images/calendar.gif",
		dateFormat: "mm/dd/yy",
		changeMonth: true,
		changeYear: true,
		numberOfMonths: 1
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
			open: function()
			{
				$("#comment_dialog_form").dialog("open");
			},
      close: function() {
        $('#comment_dialog-form').dialog("close");
        $(this).find('form')[0].reset();
      }
		}).prev ().find(".ui-dialog-titlebar-close").show();
		return false
	});
});

$(function() {
	$("#cancel_action").bind("click",function() {
		$("#comment_dialog_form").reset();
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

$(function() {
	$("#plan_states_history").hide();
	$("#show_plan_states_history").click(function(event){
		event.preventDefault();
		$("#plan_states_history").show();
	});
});

$(function() {
	$("#hide_plan_states_history").click(function(event){
		event.preventDefault();
		$("#plan_states_history").hide();
	});
});

$(function() {
	$('#visibility_dialog_form').hide();
	$('#change_visibility_link').click(function(event) {
		event.preventDefault();
		$('#visibility_dialog_form').dialog( {
			width: 400,
			height: 250,
			modal: true,
			closeOnEscape: true,
			draggable: true,
			resizable: false,
			title: "Share my DMP",
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
				$("#visibility_dialog_form").dialog("open");
			},
      close: function() {
        $('#visibility_dialog_form').dialog("close");
        $(this).find('form')[0].reset();
      }
		}).prev ().find(".ui-dialog-titlebar-close").show();
		return false
	});
});

$(function() {
	$("#cancel_action").bind("click",function() {
		$("#visibility_dialog_form").reset();
	});
});