function supports_html5_storage() {
  try {
    return 'localStorage' in window && window['localStorage'] !== null;
  } catch (e) {
    return false;
  }
}

var saveSelectOnUpdate = function (event) {
  var select = $(event.target);
  var selected = [];
  select.find('option:selected').each(function () {
    selected.push($(this).val())
  });

  localStorage[select.attr("name")] = selected;
}

var saveOnUpdate = function (event) {
  var input = event.srcElement;
  localStorage[$(input).attr('name')] = $(input).val();
}

var loadLocalStorage = function () {
  console.log("loading local storage");

  for (i = 0; i < localStorage.length; i++) {
    var key = localStorage.key(i);
    var value = localStorage.getItem(key);

    var element = $('[name='+key+']');

    if(element.prop("tagName") === "SELECT") {
      var vals = value.split(",");
      element.val(vals).trigger("liszt:updated");
    } else {
      element.val(value);
    }
  }
}

jQuery(function () {
  if(supports_html5_storage() === true ) {
    console.log('ready to rock');
    loadLocalStorage();
  } else {
    $('#flash').append('<div class="error">Your browser does not support local storage, be careful.</div>');
  }

  $('.chzn-select').chosen();

  $('input[name]').keyup(saveOnUpdate);
  $('textarea').keyup(saveOnUpdate);
  $('.chzn-select').chosen().change(saveSelectOnUpdate);
});