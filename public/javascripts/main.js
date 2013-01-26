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

var buttonToggles = function ($label) {
  var input = $label.prev();

  var radios = $(input).siblings('[type=radio]');

  _.each(radios, function (radioInput) {
    $(radioInput).next().removeClass('checked');
    $(radioInput).removeAttr('checked');
  });


  $label.siblings().removeAttr('checked');
  $label.siblings().removeClass('checked');

  if ($(input).attr('type') === "radio") {
    console.log($(input).prop('checked'))

    if ($label.hasClass('checked')) {
      $('.null-radio').attr('checked',true)
      $('.assignment-brief').html('');
      return false;
    } else {
      if ($(input).hasClass('assignment-input')) {
        $('.assignment-brief').html("<h6>Brief</h6>"+$(input).data().brief)
      }
    }
  }

  $label.toggleClass('checked');
}

var confirmDelete = function () {
  if (confirm("Are you sure you want to delete this? This action cannot be undone")) {

  } else {
    return false;
  }
}

jQuery(function() {
  $('.delete-link').click(confirmDelete);

  $('.button-labels label').click(function() {
    buttonToggles($(this));
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