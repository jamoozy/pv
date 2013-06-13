
var photos = (function() {
  function show_viewer(evt) {
    evt.stopPropagation();
    $('#overlay').show();
    $('#exit-bg').show();

    // Find best position/size for image.
    $('#overlay').find('img').attr('src', $(evt.target).attr('src'));
  }

  function hide_viewer(evt) {
    evt.stopPropagation();
    $('#overlay').hide();
    $('#exit-bg').hide();
  }

  function kill_event(evt) {
    evt.stopPropagation();
  }

  return {
    init : function() {
      $('li').find('span').click(show_viewer);

      $('#overlay').click(kill_event);
      $('#exit-bg').click(hide_viewer);
    }
  };
})();

$(window).load(photos.init);
