function postComment(comment) {
  if (S(comment['content']).isEmpty()) {
    return alert("The comment field was blank")
  }

  $.post('/comments/new', comment, function (data) {
    if (data.error) { return alert('There was a problem posting your comment. Please try again.')}

      console.log(data)

    var templateSource = $('#comment-template').html();
    var template = Handlebars.compile(templateSource);
    $('.comment-list').prepend(template(data.comment));
    $('#new-comment-textarea').val('')
  });
}

// http://www.alistapart.com/articles/expanding-text-areas-made-elegant/
function makeExpandingArea(container) {
 var area = container.querySelector('textarea');
 var span = container.querySelector('span');
 if (area.addEventListener) {
   area.addEventListener('input', function() {
     span.textContent = area.value;
   }, false);
   span.textContent = area.value;
 } else if (area.attachEvent) {
   // IE8 compatibility
   area.attachEvent('onpropertychange', function() {
     span.innerText = area.value;
   });
   span.innerText = area.value;
 }
 // Enable extra CSS
 container.className += ' active';
}

var bindExpandingAreas = function () {
  var areas = document.getElementsByClassName('expanding-area');
  var l = areas.length;

  while (l--) {
   makeExpandingArea(areas[l]);
  }
}

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

  bindExpandingAreas();

  $('.new-comment button').click(function () {
    postComment({
      userId: $(this).closest('.new-comment').data().userId,
      postId: $(this).closest('.new-comment').data().postId,
      content: S($(this).closest('.new-comment').find('textarea').val()).escapeHTML().s
    });
  });
});