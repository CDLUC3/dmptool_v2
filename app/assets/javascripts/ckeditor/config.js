
if(typeof(CKEDITOR) != 'undefined')
{
 CKEDITOR.editorConfig = function(config) {
   config.uiColor = "#516935";
   config.toolbar = [
    [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
    [ 'NumberedList', 'BulletedList', 'HorizontalRule', 'Outdent', 'Indent' ],
    [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo', 'Find', 'Replace' ]
 ];
}
} else{
  console.log("ckeditor not loaded")
}