jQuery(function() {
  $('.button-labels label').click(function() {
    var input = $(this).prev()

    if ($(input).attr('type') === "radio") {
      $(this).siblings().removeAttr('checked');
      $(this).siblings().removeClass('checked');
    }

    $(this).toggleClass('checked')
  });

  $('.chzn-select').chosen();
});