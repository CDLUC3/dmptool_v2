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
			height: 310,
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
        window.location.reload() 
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




// share my dmp popup window
$(function() {
	$.ui.dialog.prototype._focusTabbable = function(){};
	$('#visibility_dialog_form').hide();
	$('.change_visibility_link').click(function(event) {
		event.preventDefault();
		$('#visibility_dialog_form').dialog( {
			width: 600,
			height: 200,
			modal: true,
			closeOnEscape: true,
			draggable: true,
			resizable: false,
			title: "Share my DMP",
			
		 	buttons: {
				Cancel: function(){
					//$('#ui-id-1').unwrap();
					$(this).dialog( "close" );
				},
				Submit: function() {

          $("#visibility_form").submit();
          $(this).dialog( "close" );
				}
			},
			open: function()
			{   

        $('.ui-widget-overlay').addClass('custom-overlay');
        
        $('#visibility_dialog_form').prev().css('color', '#4C4C4E');
        $('#visibility_dialog_form').prev().css('font-family', 'Helvetica, sans-serif');
        $('#visibility_dialog_form').prev().css('font-size', '12px');
        $('#visibility_dialog_form').prev().css('line-height', '1.3');

         $('#visibility_dialog_form').prev().addClass('modal-header');

        $('#visibility_dialog_form').parent().addClass(' in');

        $('#visibility_dialog_form').prev().find('button').addClass('custom-close');
        $('#visibility_dialog_form').prev().find('button').css('background','none');
        $('#visibility_dialog_form').prev().find('button').css('border','none');
        $('#visibility_dialog_form').prev().find('button').css('font-color','black');
        $('#visibility_dialog_form').prev().find('button').css('font-size','20');
        $('#visibility_dialog_form').prev().find('button').css('font-color','black');
        $('#visibility_dialog_form').prev().find('button').css('opacity','0.2');
               
    		$(this).parent().find('button:contains("Cancel")').removeClass('ui-corner-all');
    		$(this).parent().find('button:contains("Cancel")').removeClass('ui-widget');
    		$(this).parent().find('button:contains("Cancel")').removeClass('ui-button');
    		$(this).parent().find('button:contains("Cancel")').removeClass('ui-state-default');
    		$(this).parent().find('button:contains("Cancel")').removeClass('ui-button-text-only');
				$(this).parent().find('button:contains("Cancel")').addClass('btn');
				

    		$(this).parent().find('button:contains("Submit")').removeClass('ui-corner-all');
    		$(this).parent().find('button:contains("Submit")').removeClass('ui-widget');
    		$(this).parent().find('button:contains("Submit")').removeClass('ui-button');
    		$(this).parent().find('button:contains("Submit")').removeClass('ui-state-default');
    		$(this).parent().find('button:contains("Submit")').removeClass('ui-button-text-only');
				$(this).parent().find('button:contains("Submit")').removeClass('ui-button-text');
				$(this).parent().find('button:contains("Submit")').addClass('btn btn-green confirm');			

				$('#ui-id-1').parent().removeClass('ui-widget-overlay');
				$('#ui-id-1').parent().removeClass('ui-widget-header');
				$('#ui-id-1').parent().removeClass('ui-dialog-title');
				$('#ui-id-1').parent().addClass('modal-header');
				
				// $('#ui-id-1').css('font-weight','bold');
				// $('#ui-id-1').css('font-family', 'Helvetica, sans-serif');
				// $('#ui-id-1').css('font-size', '12px');

				
				$('#ui-id-1').wrap("<h3 id=\"new_h3\"><strong id=\"new_strong\"></strong></h3>");

				$('#visibility_dialog_form').next().removeClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix');
				$('#visibility_dialog_form').next().addClass('modal-footer');	

				$("#visibility_dialog_form").dialog("open");
				$(".copyright span7").hide();
			},
      close: function() {
      	$('#ui-id-1').first().unwrap();
      	$('#ui-id-1').first().unwrap();
        $('#visibility_dialog_form').dialog("close");
        
        //window.location.reload(true);
      }
		}).prev ().find(".ui-dialog-titlebar-close").show();
		return false
	});
});


$(function() {
	$('#visibility_dialog_form').parent().find('button:contains("Cancel")').bind("click",function() {
		$("#visibility_dialog_form").reset();
	});
});


$(function() {
	$(".change_visibility_link").bind("click",function() {
		var id= $(this).data('planid');
		var visibility = $(this).data('visibility');

		$("#shared_plan_id").val(id);

		if (visibility  == "institutional")
		{
			$("#visibility_institutional").click();
		}
		else if (visibility  == "public")
	  {
	  	$("#visibility_public").click();
	  }
		else if (visibility  == "private")
	  {
	  	$("#visibility_private").click();
	  }
	  else if (visibility  == "unit")
	  {
	  	$("#visibility_unit").click();
	  }
	});
});

$(function() {
	$('#reject_dialog_form').hide();
	$('#reject_with_comments_link').click(function(event) {
		event.preventDefault();
    $('#comment_comment_type').attr('value', $(event.target).attr("data-comment-type"));
		$('#reject_dialog_form').dialog( {
			width: 450,
			height: 270,
			modal: true,
			closeOnEscape: true,
			draggable: true,
			resizable: false,
			title: "Reason for rejection (mandatory)",
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
				$("#reject_dialog_form").dialog("open");
			},
      close: function() {
        $('#reject_dialog-form').dialog("close");
        $(this).find('form')[0].reset();
      }
		}).prev ().find(".ui-dialog-titlebar-close").show();
		return false
	});
});

$(function() {
	$("#cancel_action").bind("click",function() {
		$("#reject_dialog_form").reset();
	});
});
