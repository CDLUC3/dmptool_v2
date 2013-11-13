// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('#requirements_tree').jstree({
    "plugins" : ["themes", "html_data", "ui"],
    "themes" : {
      theme : 'default',
      icons : false
    }
  });
});