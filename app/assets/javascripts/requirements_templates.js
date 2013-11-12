// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
	$("#start_date.datepicker").datepicker( {
		showOn: 'button',
		buttonImage: "http://jqueryui.com/resources/demos/datepicker/images/calendar.gif",
		dateFormat: "mm/dd/yy",
		changeMonth: true,
		changeYear: true,
		numberOfMonths: 2,
		onClose: function( selectedDate ) {
			$( "#end_date.datepicker" ).datepicker( "option", "minDate", selectedDate );
		}
	});

	$("#end_date.datepicker").datepicker( {
		showOn: 'button',
		buttonImage: "http://jqueryui.com/resources/demos/datepicker/images/calendar.gif",
		dateFormat: "mm/dd/yy",
		changeMonth: true,
		changeYear: true,
		numberOfMonths: 2,
		onClose: function( selectedDate ) {
			$( "#start_date.datepicker" ).datepicker( "option", "maxDate", selectedDate );
		}
	});

	$("form").on('click','.add_fields', function(event) {
	  var time = new Date().getTime();
	  var regexp = new RegExp($(this).data('id'), 'g');
	  $(this).before($(this).data('fields').replace(regexp, time));
	  event.preventDefault();
	});

	$("form").on('click','.remove_fields', function(event) {
		$(this).prev('input[type=hidden]').val('1');
		$(this).closest('.control-group').hide();
		event.preventDefault();
	});

});

$(function() {
	$(".show_on_hover").hide();
		$("td.requirements_template_name").bind("mouseenter mouseleave",function()
		{
			$(this).closest('tr').next().find('.show_on_hover').slideToggle("slow");
		});
});

$(function() {
	$('#role_dialog_form').hide();
	$('#add_requirements_editor_role_view').click(function() {
		$('#role_dialog_form').dialog( {
			width: 800,
			height: 200,
			modal: true,
			closeOnEscape: true,
			draggable: true,
			resizable: false,
			title: "Add New Role",
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
				$("#role_dialog_form").dialog("open");
			},
      close: function() {
        $('#role_dialog-form').dialog("close");
        $(this).find('form')[0].reset();
      }
		}).prev ().find (".ui-dialog-titlebar-close").show();
		return false
	});
});

$(function() {
	$("#cancel_action").bind("click",function() {
		$(".flash_notice").remove();
	});
})
