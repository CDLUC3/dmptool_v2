// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$(function() {
	$("fieldset.requirement_type_enum").hide();
	$(document).on("ready", showHideEnum());
	$("#requirement_requirement_type").bind('change', function(){
		showHideEnum();
	});

	function showHideEnum() {
		if($("#requirement_requirement_type").val() == "enum") {
			$("fieldset.requirement_type_enum").show();
		} else {
			$("fieldset.requirement_type_enum").hide();
		}
	}
});

$(function() {
  $("fieldset.requirement_type_numeric").hide();
  $(document).on("ready", showHideLabel());
  $("#requirement_requirement_type").bind('change', function(){
    showHideLabel();
  });

  function showHideLabel() {
    if($("#requirement_requirement_type").val() == "numeric") {
      $("fieldset.requirement_type_numeric").show();
    } else {
      $("fieldset.requirement_type_numeric").hide();
    }
  }
});

$(function() {
if(window.location.pathname.indexOf("new") > 0){
  $("#cancel_button").click(function() {
  var value = $("#requirement_requirement_type").val();
  switch (value) {
  case "numeric":
    $("fieldset.requirement_type_numeric").hide();
    break;
  default:
    break;
  }
  });
}
});

// from http://nack.co/get-url-parameters-using-jquery/ to check parameters.
$.urlParam = function(name){
    var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (!results) { return ''; }
    return results[1] || 0;
};
$(document).ready(function() {
	if($.urlParam('node_type') == 'group') {
		$("#optional").prop('checked', false);
  	$("#requirement_text_full, #requirement_requirement_type, #mandatory, #mandatory_applicable, #recommended, #optional").prop("disabled", true);
    $("#if_group").prop('checked', true);
  	$("#requirement_requirement_type option:selected").remove();
  	$("#requirement_requirement_type option:selected").remove();
  	$("#requirement_requirement_type option:selected").remove();
  	$("#requirement_requirement_type option:selected").remove();
 	}
});



/* For the index.html.erb action in requirements */

$( document).ready(function() {
  addEventsToTree();
});

function addEventsToTree(){
  $('a.requirements_text').draggable({
    containment: '#main_requirements_border',
    cursor: 'move',
    // snap: 'div.requirements_group',
    stack: 'div.requirements_group',
    revert: true
  });

  $('div.requirements_group').droppable( {
    drop: handleDropEvent
  });

  $('#drop_before_first').droppable( {
    drop: handleDropEvent
  });
}

function handleDropEvent( event, ui ) {
  $(event.target).draggable({
    revertDuration: 0
  });
  var draggable = ui.draggable;
  var drag_id = draggable.attr('id').match(/\d+$/g);
  if(event.target.id == 'drop_before_first'){
    var drop_id = event.target.id;
  }else{
    var drop_id = event.target.id.match(/\d+$/g);
  }

  $("#cover_dialog").show();
  $.ajax({
    url: '/requirements/reorder', // ' reorder_requirements_path() ',
    type: 'post',
    data: { drag_id: drag_id, drop_id: drop_id },
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    error: function (xhr, ajaxOptions, thrownError) {
      $("#cover_dialog").hide();
    }
  });
}

/* end for the requirements/index.html.erb action */
