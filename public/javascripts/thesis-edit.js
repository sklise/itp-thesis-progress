$(function () {
  var inputs = ['title', 'synopsis', 'description'];

  inputs.forEach(function(input) {
    remainingCharacters('#'+input+'-count', $('#thesis-'+input+'-input').val().length);
    $('#thesis-'+input+'-input').bind('input', function () {
      remainingCharacters('#'+input+'-count', $(this).val().length);
    });
  })

});

var remainingCharacters = function (div, l) {
  var countDiv = $(div);
  var max = countDiv.data()['max'];
  var remaining = countDiv.data()['max'] - l;
  countDiv.html(remaining)
  if (remaining <= 0) {
    countDiv.removeClass().addClass('over')
  } else if (remaining < (max * .25)) {
    countDiv.removeClass().addClass('danger-zone')
  } else {
    countDiv.removeClass()
  }
}