function supports_html5_storage() {
  try {
    return 'localStorage' in window && window['localStorage'] !== null;
  } catch (e) {
    return false;
  }
}

var saveOnUpdate = function (event) {

  var input = event.srcElement;
  console.log(input)
  localStorage[$(input).attr('name')] = $(input).val()
}

var loadLocalStorage = function () {
  console.log("loading local storage")

  for (i = 0; i < localStorage.length; i++) {
    var key = localStorage.key(i);
    var value = localStorage.getItem(key);

    var element = $('[name='+key+']');

    element.val(value);
  }
}

jQuery(function () {
  if(supports_html5_storage() === true ) {
    console.log('ready to rock')
    loadLocalStorage();
  } else {
    $('#flash').append('<div class="error">Your browser does not support local storage, be careful.</div>');
  }
  $('.chzn-select').chosen()

  $('input').keyup(saveOnUpdate);
  $('textarea').keyup(saveOnUpdate);
});