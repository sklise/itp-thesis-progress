// http://blog.alexmaccaw.com/svbtle-image-uploading
(function($){
  function dragEnter(e) {
    $(e.target).addClass("dragOver");
    e.stopPropagation();
    e.preventDefault();
    return false;
  };

  function dragOver(e) {
    e.originalEvent.dataTransfer.dropEffect = "copy";
    e.stopPropagation();
    e.preventDefault();
    return false;
  };

  function dragLeave(e) {
    $(e.target).removeClass("dragOver");
    e.stopPropagation();
    e.preventDefault();
    return false;
  };

  $.fn.dropArea = function(){
    this.bind("dragenter", dragEnter).
         bind("dragover",  dragOver).
         bind("dragleave", dragLeave);
    return this;
  };

  var insertAtCaret = function(value) {
    if (document.selection) { // IE
      this.focus();
      var sel = document.selection.createRange();
      sel.text = value;
      this.focus();
    }
    else if (this.selectionStart || this.selectionStart == '0') {
      var startPos  = this.selectionStart;
      var endPos    = this.selectionEnd;
      var scrollTop = this.scrollTop;

      this.value = [
        this.value.substring(0, startPos),
        value,
        this.value.substring(endPos, this.value.length)
      ].join('');

      this.focus();
      this.selectionStart = startPos + value.length;
      this.selectionEnd   = startPos + value.length;
      this.scrollTop      = scrollTop;

    } else {
      throw new Error('insertAtCaret not supported');
    }
  };

  $.fn.insertAtCaret = function(value){
    $(this).each(function(){
      insertAtCaret.call(this, value);
    })
  };
})(jQuery);

var createAttachment = function(file) {
  var uid  = [$('body').data().netid, (new Date).getTime()].join('-');

  var data = new FormData();

  var slugifiedName = S(file.name).dasherize().escapeHTML().s;

  data.append('attachment[name]', slugifiedName);
  data.append('attachment[file]', file);
  data.append('attachment[uid]',  uid);

  $.ajax({
    url: '/attachments',
    data: data,
    cache: false,
    contentType: false,
    processData: false,
    type: 'POST',
  }).fail(function () {
    // ...
  }).done(function () {
    $('button').removeAttr('disabled');
  });

  var absText = '![' + file.name + '](http://itp-thesis.s3.amazonaws.com/' + uid + '/' + slugifiedName + ')';
  $('.expanding-area textarea').insertAtCaret(absText);
};

var createResource = function (file) {
  var data = new FormData();

  var slugifiedName = S(file.name).dasherize().escapeHTML().s;

  data.append('attachment[name]', slugifiedName);
  data.append('attachment[file]', file);

  $.ajax({
    url: '/attachments/resources',
    data: data,
    cache: false,
    contentType: false,
    processData: false,
    type: 'POST',
  }).fail(function () {
    // ...
  }).done(function () {
    $('button').removeAttr('disabled');
  });

  var absText = '[' + file.name + '](http://itp-thesis.s3.amazonaws.com/'
    + 'resources/'
    + slugifiedName + ')';
  $('.expanding-area textarea').insertAtCaret(absText);
};

$(function () {
  $('body').dropArea();

  $('body').bind('drop', function(e){
    e.preventDefault();
    e = e.originalEvent;

    $('button').attr('disabled',true);

    var files = e.dataTransfer.files;

    for (var i = 0, l = files.length; i < l; i++) {
      if (location.pathname === "/resources/edit") {
        createResource(files[i]);
      } else if (/image/.test(files[i].type)) {
        createAttachment(files[i]);
      }
    };
  });
});