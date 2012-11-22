// http://www.alistapart.com/articles/expanding-text-areas-made-elegant/
function makeExpandingArea(container) {
 var area = container.querySelector('textarea');
 var span = container.querySelector('span');

 remainingCharacters(area.value);

 if (area.addEventListener) {
   area.addEventListener('input', function() {
    remainingCharacters(area.value);
    span.textContent = area.value;
   }, false);
   span.textContent = area.value;
 } else if (area.attachEvent) {
   // IE8 compatibility
   area.attachEvent('onpropertychange', function() {
    remainingCharacters(area.value);
     span.innerText = area.value;
   });
   span.innerText = area.value;
 }
 // Enable extra CSS
 container.className += ' active';
}

window.onload = function() {
  var areas = document.getElementsByClassName('expanding-area');
  var l = areas.length;

  while (l--) {
   makeExpandingArea(areas[l]);
  }
}

var remainingCharacters = function (text) {
  var charCount = $('#char-count')
  var remaining = charCount.data()['max'] - text.length;
  charCount.html(remaining);
  if (remaining <= 0) {
    charCount.removeClass().addClass('over')
  } else if (remaining < 100) {
    charCount.removeClass().addClass('danger-zone')
  } else {
    console.log('ok')
    charCount.removeClass()
  }
}

var supports_html5_storage = function () {
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