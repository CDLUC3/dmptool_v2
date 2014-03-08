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
	$('.add_comments_link').click(function(event) {
		event.preventDefault();
    $('#comment_comment_type').attr('value', $(event.target).attr("data-comment-type"));
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
});

$(function() {
	$("#reviewer_comments, .hide-reviewer-comments").hide();
	$(".view-reviewer-comments").click(function(event){
		event.preventDefault();
		$("#reviewer_comments").show();
		$(".view-reviewer-comments").hide();
		$(".hide-reviewer-comments").show();
	});
});

$(function() {
	$(".hide-reviewer-comments").click(function(event){
		event.preventDefault();
		$("#reviewer_comments").hide();
		$(".hide-reviewer-comments").hide();
		$(".view-reviewer-comments").show();
	});
});

$(function() {
	$("#owner_comments, .hide-owner-comments").hide();
	$(".view-owner-comments").click(function(event){
		event.preventDefault();
		$("#owner_comments").show();
		$(".view-owner-comments").hide();
		$(".hide-owner-comments").show();
	});
});

$(function() {
	$(".hide-owner-comments").click(function(event){
		event.preventDefault();
		$("#owner_comments").hide();
		$(".hide-owner-comments").hide();
		$(".view-owner-comments").show();
	});
});

$(function() {
	$("#plan_history, .hide-plan-history").hide();
	$(".view-plan-history").click(function(event){
		event.preventDefault();
		$("#plan_history").show();
		$(".view-plan-history").hide();
		$(".hide-plan-history").show();
	});
});

$(function() {
	$(".hide-plan-history").click(function(event){
		event.preventDefault();
		$("#plan_history").hide();
		$(".hide-plan-history").hide();
		$(".view-plan-history").show();
	});
});

$(function() {
	$('#visibility_dialog_form').hide();
	$('.change_visibility_link').click(function(event) {
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
		 	buttons: {
				Cancel: function()
				{
					$(this).dialog( "close" );
				}
			},
			open: function()
			{
				$("#visibility_dialog_form").dialog("open");
			},
      close: function() {
        $('#visibility_dialog_form').dialog("close");
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