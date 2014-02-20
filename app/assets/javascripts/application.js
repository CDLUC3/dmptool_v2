// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require bootstrap
//= require jquery.ui.all
//= require jquery_ujs
//= require ckeditor-jquery
//= require_tree .


$.rails.allowAction = function(link) {
  if (!link.attr('data-confirm')) {
    return true;
  }
  $.rails.showConfirmDialog(link);
  return false;
};

$.rails.confirmed = function(link) {
  link.removeAttr('data-confirm');
  return link.simulate('click');
};

$.rails.showConfirmDialog = function(link) {
  var html, message, yesVal, noVal;
  message = link.attr('data-confirm');
  yesVal = (typeof link.attr('data-yesval') === 'undefined' ? 'Delete': link.attr('data-yesval'));
  noVal = (typeof link.attr('data-noval') === 'undefined' ? 'Cancel': link.attr('data-noval'));
  html =	"<div class=\"modal\" id=\"confirmationDialog\">\n" +
  					"<div class=\"modal-header\">\n" +
  						"<a class=\"close\" data-dismiss=\"modal\">×</a>\n" +
  						"<h3><strong>" + message + "</strong></h3>\n" +
  					"</div>\n" +
  					"<div class=\"modal-footer\">\n" +
  						"<a data-dismiss=\"modal\" class=\"btn\">" + noVal + "</a>\n" +
  						"<a data-dismiss=\"modal\" class=\"btn btn-green\">" + yesVal + "</a>\n" +
  					"</div>\n" +
  				"</div>";
  $(html).modal();
  return $('#confirmationDialog .confirm').on('click', function() {
    return $.rails.confirmed(link);
  });
};

function tab_jump(){
	// allows jumping to specific tab with Twitter Bootstrap on page load
	// The tab to jump to is specified in the url hash with something like #tab_tab2
	// it must start with 'tab_' and after that have the string for the tab to go to.
	// see http://stackoverflow.com/questions/7862233/twitter-bootstrap-tabs-go-to-specific-tab-on-page-reload
	// and the answer by greggdavis
	var hash = document.location.hash;
	var prefix = "tab_";

	if (hash) {
    hash = hash.replace(prefix,'');
    var hashPieces = hash.split('?');
    activeTab = $('.nav-tabs a[href=' + hashPieces[0] + ']');
    activeTab && activeTab.tab('show');
	}

	// Change hash for page-reload
	$('.nav-tabs a').on('shown', function (e) {
    window.location.hash = e.target.hash.replace("#", "#" + prefix);
	});
}

function add_tab_to_pagination(){
	// this adds the #tab_tab1 (example) to the pagination links
	// so that the correct tab is selected.  It is based on div.tab-pane
	// and nav.pagination css classes it can find in the page.
	$( "div.tab-pane" ).each(function( index ) {
  	//console.log( index + ": " + this.id );
  	var my_id = this.id;
  	$("#" + my_id + " nav.pagination a").attr("href", function(i, href) {
  		if(href.match(/#tab_[a-zA-Z0-9_-]+$/)){
  			return href;
  		}else{
  			return href + "#tab_" + my_id;
  		}
  	});
	});
}
