jQuery(function() {
  $('.button-labels label').click(function() {
    var input = $(this).prev()

    var radios = $(input).siblings('[type=radio]');

    _.each(radios, function (radioInput) {
      $(radioInput).next().removeClass('checked');
      $(radioInput).removeAttr('checked');
    });

    if ($(input).attr('type') === "radio") {
      $(this).siblings().removeAttr('checked');
      $(this).siblings().removeClass('checked');
    }

    $(this).toggleClass('checked')
  });

  $('span.markdown-mark').click(function() {
    $('#markdown-wrapper').toggle();
  });

  $('#markdown-wrapper').click(function(e) {
    if(e.target === $(this)[0]) {
      $(this).hide();
    }
  })

  $('.chzn-select').chosen();
});