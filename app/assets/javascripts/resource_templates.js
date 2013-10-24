// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
	$(".show_on_hover").hide();
		$("td.resource_template_name").bind("mouseenter mouseleave",function()
		{
			$(this).closest('tr').next().find('.show_on_hover').slideToggle("slow");
		});

	$(".selected_requirements_template").click(function(){
		var chosen_id = $('input[name=requirements_template_id]:checked').val();
		var chosen_name = $(this).closest('tr').find('td.selected_requirements_template_name').text();
		$("#requirements_template_id").val(chosen_id);
		$("#selected_requirement_template_name").val(chosen_name);
	});

});