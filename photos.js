

// TODO's:  Handle resizing after overlay is shown.

var photos = (function() {
  // Dirty, dirty constants.
  var MARGINS = 15;     // (pixels assumed)
  var MIN_MARGIN = 100; // (pixels assumed)

  function get_dir_img_from_img() {
    return $("#overlay").find('img').attr("src").split("/");
  }

  function get_all_comments() {
    var dir_img = get_dir_img_from_img();
    window.console.log('Getting title/comments for "' + dir_img[0] + '/' + dir_img[1] + '"');
    $.get('dbi.rb', {
      dir:dir_img[0],
      type:'fetch',
      img:dir_img[1]
    }, function(json) {
      window.console.log("Got json:\n"+json);
      eval('var obj='+json);
      if (obj.error !== undefined) {
        window.console.log("Error from server:\n" + obj.error);
      } else {
        window.console.log("Got\ntitle:"+obj.title+"\ncomments:"+obj.comments);
        $("#desc").html(obj.title);
        $("#comments").find('ul').html(obj.comments);
      }
    });
  }

  function show_viewer(evt) {
    evt.stopPropagation();

    var overlay = $('#overlay');
    var desc = $('#desc');
    var comments = $('#comments');
    var img = overlay.find('img');
    var form = $("#form");

    overlay.show();
    $('#exit-bg').show();

    var src = $(evt.target).parent().attr('src');
    img.attr('src', src);

    fit();

    get_all_comments();
  }

  // Find best position/size for image.
  // TODO Center also.
  function fit() {
    var overlay = $('#overlay');
    var desc = $('#desc');
    var comments = $('#comments');
    var img_pane = $("#img-pane");
    var img = img_pane.find("img");
    var form = $("#form");

    var max_width = overlay.width() - desc.outerWidth() - 3 * MARGINS;
    var max_height = overlay.height() - 2*MARGINS;
    img.css('max-width', max_width + 'px');
    img.css('max-height', max_height + 'px');
    img_pane.css('width', max_width + 'px');
    img_pane.css('height', max_height + 'px');

    var ml = '' + (max_width + 2*MARGINS) + 'px';
    desc.css('margin-left', ml);
    comments.css('margin-left', ml);

    $("#comment-pane").css('max-height', (overlay.height() - desc.outerHeight() - form.outerHeight() - 4*MARGINS-5) + 'px');
  }

  function hide_viewer(evt) {
    evt.stopPropagation();
    $('#overlay').hide();
    $('#exit-bg').hide();
  }

  function kill_event(evt) { evt.stopPropagation(); }

  function send_comment() {
    var dir_img = get_dir_img_from_img();
    var name = $("#name").prop('value');
    var comment = $("#comment").prop('value');
    window.console.log("Sending\nname:" + name + "\ncomment:" + comment);
    $.get('dbi.rb', {
      dir:dir_img[0],
      type:'put',
      name:name,
      comment:comment,
      img:dir_img[1]
    }, function(json, textStatus) {
      window.console.log("status:"+textStatus);
      if (textStatus === 'success') {
        get_all_comments();
        $("#name").prop('value', '')
        $("#comment").prop('value', '')
      } else {
        eval("var err="+json);
        window.console.log("error:"+err.error);
      }
    });
  }

  return {
    init : function() {
      $('li').find('span').click(show_viewer);

      $('#overlay').click(kill_event);
      $('#exit-bg').click(hide_viewer);
      $('#submit').click(send_comment);
      $(window).resize(fit);
    }
  };
})();

$(window).load(photos.init);
