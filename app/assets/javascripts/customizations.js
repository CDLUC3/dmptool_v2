// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( document ).ready(function() {
  $("a.show_full").click(function(event) {
    event.preventDefault();
    t = $(this)
    t.parent().hide("slow", "swing");
    my_id = t.parent().attr('id').match(/\d+$/)[0];
    $("#resource_text_full_" + my_id).show("slow", "swing");
  });

  $("a.show_brief").click(function(event) {
    event.preventDefault();
    t = $(this)
    t.parent().hide("slow", "swing");
    my_id = t.parent().attr('id').match(/\d+$/)[0];
    $("#resource_text_trunc_" + my_id).show("slow", "swing");

  });

  // this adds the #tab_tab1 (example) to the requirement links
  // as they are clicked so they stay on the same tab when clicking through pages.
  $('a.requirement_direct_link').click(function(event) {
    var match = location.href.match(/#tab_[a-zA-Z0-9_-]+$/);
    if(!match){
      match = '#tab_tab1';
    }
    else{
      match = match[0];
    }
    this.href = this.href + match;
  });
});

