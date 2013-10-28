// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function(){
	$("fieldset.requirement_type").hide();
	$("#requirement_requirement_type").change(function(){
		if($("#requirement_requirement_type").val() == "enum") {
			$("fieldset.requirement_type").show();
		} else {
			$("fieldset.requirement_type").hide();
		}
	});
});

	$(function(){
	 	$("#add_requirement_group").click(function(e) {
	 		e.preventDefault();
	 		$("#if_group").prop('checked', true);
			$("#requirement_text_full, #requirement_requirement_type").prop("disabled", true);
		});
	});


$(function() {
  $('.requirements_tree_view').jstree({
    plugins: ['themes', 'ui'],
    themes: {
      theme : 'default',
      icons : false
    }
  });
});
