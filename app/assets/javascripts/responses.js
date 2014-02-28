// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
	$('#save_only').bind("click",function(e) {
    var selected = $("#response_value").val();
    alert(selected);
    if(selected == ""){
      $('#alert_message').dialog('open');
      e.preventDefault();
    }else{
      // let it go ahead
    }
  });

  $('#alert_message').dialog({
      autoOpen: false,
      width: 400,
      height: 100,
      modal: true,
      closeOnEscape: true,
      draggable: true,
      resizable: false,
      autoOpen: false,
      title: "Please Enter a Valid Response.",
      show: {
        effect: "blind"
      },
      hide: {
        effect: "toggle"
      },
      open: function()
      {
        $('#alert_message').dialog("open");
      },
      close: function() {
        $('#alert_message').dialog("close");
      }
  });
});