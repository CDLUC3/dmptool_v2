// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
	$('#dialog_form').hide();
	$('#add_role_view').click(function() {
		$('#dialog_form').dialog( {
			width: 800,
			height: 200,
			modal: true,
			closeOnEscape: true,
			draggable: true,
			resizable: false,
			title: "Add New Editor",
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
		$("#flash_notice").reset();
	});
})