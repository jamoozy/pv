

// TODO's:  Handle resizing after overlay is shown.

var photos = (function() {
  // Dirty, dirty constants.
  var MARGINS = 15;     // (pixels assumed)
  var MIN_MARGIN = 100; // (pixels assumed)

  function show_viewer(evt) {
    evt.stopPropagation();
    $('#overlay').show();
    $('#exit-bg').show();

    // Find best position/size for image.
    // TODO Center also.
    var overlay = $('#overlay');
    var desc = $('#desc');
    var comments = $('#comments');
    var img = overlay.find('img');

    img.attr('src', $(evt.target).parent().attr('src'));
    var max_width = overlay.width() - desc.outerWidth() - 3 * MARGINS;
    img.css('max-width', '' + max_width + 'px');
    img.css('max-height', '' + (overlay.height() - 2*MARGINS) + 'px');

    var ml = '' + (max_width + 2*MARGINS) + 'px';
    desc.css('margin-left', ml);
    comments.css('margin-left', ml);
  }

  function hide_viewer(evt) {
    evt.stopPropagation();
    $('#overlay').hide();
    $('#exit-bg').hide();
  }

  function kill_event(evt) { evt.stopPropagation(); }

  return {
    init : function() {
      $('li').find('span').click(show_viewer);

      $('#overlay').click(kill_event);
      $('#exit-bg').click(hide_viewer);
    }
  };
})();

$(window).load(photos.init);
