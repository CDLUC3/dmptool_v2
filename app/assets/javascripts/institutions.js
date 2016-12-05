// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
	$('#dialog_form').hide();
	$('#add_authorization_view').click(function() {
		$('#dialog_form').dialog( {
			width: 800,
			height: 200,
			modal: true,
			closeOnEscape: true,
			draggable: true,
			resizable: false,
			title: "Grant New Role",
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
				$("#dialog_form").dialog("open");
			},
      close: function() {
        $('#dialog-form').dialog("close");
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
});


$(function() {
	$(".tip").tooltip();
});


// //automatically checks Institutional reviewer role when Institutional Administrator role gets checked
$(function() {
	$('#5').change(function(){
		if ($('#5').is(':checked')) { 
			$('#4').prop('checked', true);
		}
	});
});

// alert message if Institutional Admin remove his own Inst admin role
$(function() {
	$('#current_admin_with_alert').click(function(){
		if (!$('#5').is(':checked')) { 
			if (confirm( "Do you really want to remove yourself from the Institutional Administrator role? You will lose all administrative permissions.")){
				return true;
 			} else {
				return false;
			};
		};
	});
});

$.extend({ alert: function (message, title) {
  $("<div></div>").dialog( {
    buttons: { "Ok": function () { $(this).dialog("close"); } },
    close: function (event, ui) { $(this).remove(); },
    resizable: false,
    title: title,
    modal: true
  }).text(message);
}
});

function validateFiles(inputFile) {
  var extErrorMessage = "Only image file with extension: .jpg, .jpeg, .gif or .png is allowed";
  var allowedExtension = ["jpg", "jpeg", "gif", "png"];
  var extName;
  var extError = false;
 
  $.each(inputFile.files, function() {
    extName = this.name.split('.').pop();
    if ($.inArray(extName, allowedExtension) == -1) {extError=true;};
  });
 
  if (extError) {
    // window.alert(extErrorMessage);
    $.alert(extErrorMessage, "Wrong File Extension");
    $(inputFile).val('');
  };
}