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

// initialize expanding areas.
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

var saveLabelInputs = function (event) {
  // The input is just before the label.
  window.checkbox = $(event.target).prev()[0];

  if (typeof localStorage["labels[]"] === "undefined" || localStorage["labels[]"] === null) {
    labels = []
  } else {
    labels = JSON.parse(localStorage["labels[]"])
  }

  // This is weird, the value of .checked reflects the state before clicking.
  // So .checked == false => the box is now checked.
  if (checkbox.checked) {
    labels = _.without(labels, checkbox.value)
  } else {
    labels.push(checkbox.value)
  }

  localStorage["labels[]"] = JSON.stringify(labels)
}

var loadLocalStorage = function () {
  console.log("loading local storage");

  for (i = 0; i < localStorage.length; i++) {
    var key = localStorage.key(i);
    var value = localStorage.getItem(key);

    if (key === "labels[]") {
      loadCheckbox(value)
    } else {
      loadInput(key, value)
    }
  }
}

var loadCheckbox = function (value) {
  if (value.length === 0) {
    return false;
  }

  var checkedBoxValues = JSON.parse(value)

  checkedBoxValues.forEach(function (v) {
    var input = $('input[value="'+v+'"]')
    input.attr('checked','checked')
    input.next().addClass('checked')
  });
}

var loadInput = function (key, value) {
  var element = $('[name="'+key+'"]');

  if (element.prop("tagName") === "SELECT") {
    var vals = value.split(",");
    element.val(vals).trigger("liszt:updated");
  } else if (element.attr("type") === "checkbox") {
    console.log('hi', key, value)
  } else {
    element.val(value);
  }
}

jQuery(function () {
  $('.button-labels label').click(function() {
    $(this).toggleClass('checked')
    var input = $(this).prev()

    if (input.attr('checked') !== "undefined") {
      input.removeAttr('checked');
    }
  });

  var netid = $('h4#netid').html()
  var name = $('option[value='+netid+']').html()

  if (typeof name === 'undefined') {
    $('#your-name').html("Your netid doesn't match a member of the class of 2013")
  } else {
    $('#your-name').html(name);
  }


  if(supports_html5_storage() === true ) {
    loadLocalStorage();
  } else {
    $('#flash').append('<div class="error">Your browser does not support local storage, be careful.</div>');
  }

  $('.chzn-select').chosen();

  $('input[type=text]').keyup(saveOnUpdate);
  $('.button-labels label').mouseup(saveLabelInputs);
  $('textarea').keyup(saveOnUpdate);
  $('.chzn-select').chosen().change(saveSelectOnUpdate);

  $('form').submit(function () {
    if ($('[name=description]').val().length > 600) {
      alert("Please limit your description to 600 characters or less.");
      return false;
    }
  })
});