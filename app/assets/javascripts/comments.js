// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
	$("a.show_full").click(function(event){
    event.preventDefault();
    t = $(this);
		t.parent().hide("slow", "swing");
		my_id = t.parent().attr('id').match(/\d+$/)[0];
		$("#comment_value_full_" + my_id).show("slow", "swing");
	});

	$("a.show_less").click(function(event) {
		event.preventDefault();
		t = $(this);
		t.parent().hide("show", "swing");
		my_id = t.parent().attr('id').match(/\d+$/)[0];
		$("#comment_value_trunc_" + my_id).show("slow", "swing");
	});
});