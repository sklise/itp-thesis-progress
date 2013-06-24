// http://www.alistapart.com/articles/expanding-text-areas-made-elegant/
var makeExpandingArea = function (container) {
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

jQuery(function () {
  bindExpandingAreas();
});