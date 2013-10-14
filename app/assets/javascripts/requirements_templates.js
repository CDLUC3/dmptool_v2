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

