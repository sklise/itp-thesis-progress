$(function () {
  var inputs = ['title', 'synopsis', 'description'];

  bindCharCounts(inputs);

  $('#thesis-update-form').submit(function () {
    var stopSubmit = false;
    var over = [];

    inputs.forEach(function (input) {
      if (remainingCharacters(input) < 0) {
        stopSubmit = true;
        over.push(input);
      }
    });

    if (remainingCharacters('tags') < 0) {
      stopSubmit = true;
      over.push('tags');
    }

    if (stopSubmit) {
      $('.submit-status').show().html('You are over the character or tag limit for: ' + over.join(", "));
      return false;
    } else {
      $('.submit-status').hide().html('');
    }
  });

});

var bindCharCounts = function (inputs) {
  inputs.forEach(function(input) {
    remainingCharacters(input);

    $('#thesis-'+input+'-input').bind('input', function () {
      remainingCharacters(input);
    });
  });

  remainingCharacters('tags');

  $('#thesis-tags-input').change(function () {
    remainingCharacters('tags');
  });
}

var remainingCharacters = function (name) {
  var input = $('#thesis-' + name + '-input');
  var countDiv = $('#' + name + '-count');
  var inputVal = input.val();
  var l = 0;

  if (inputVal !== null) {
    l = inputVal.length;
  }

  var max = countDiv.data()['max'];
  var remaining = countDiv.data()['max'] - l;

  countDiv.html(remaining);

  if (remaining < 0) {
    countDiv.removeClass().addClass('over');
    input.removeClass().addClass('over');
  } else if (remaining < (max * .25)) {
    countDiv.removeClass().addClass('danger-zone');
    input.removeClass();
  } else {
    countDiv.removeClass();
    input.removeClass();
  }
  return remaining;
}