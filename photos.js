// Copyright (c) 2013 Andrew "Jamoozy" Correa,
// 
// This file is part of Picture Viewer.
// 
// Picture Viewer is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
// 
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

var photos = (function() {
  // Dirty, dirty constants.
  var MARGINS = 25;     // (pixels assumed)
  var NAV_HEIGHT = 56;
  var NAV_WIDTH = 30;

  function compute_li_min_width() {
    var max = 0;
    $('li').each(function(i, e) {
      var w = $(e).outerWidth();
      if (max < w) {
        max = w;
      }
    });

    window.console.log("Setting all li.min-width to " + max + "px");
    $('li').css('min-width', max + 'px');
  }

  function get_dir_img_from_img() {
    return $("#image").attr("src").split("/");
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
    var img = $("#image");
    var form = $("#form");

    overlay.show();
    $('#exit-bg').show();

    var src = $(evt.target).parent().attr('src');
    img.attr('src', src);

    fit();

    get_all_comments();
  }

  // Find best position/size for image.
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

    var margin_top = ((max_height - NAV_HEIGHT) / 2) + 'px';
    var margin_left = max_width - NAV_WIDTH - MARGINS;
    $(".navs").css('margin-top', margin_top);
    $("#right").css('margin-left', margin_left + 'px');
    $("#left").css('margin-left', MARGINS + 'px');
    $("#x").css('margin-top', '5px');
    $("#x").css('margin-left', (overlay.width() - 20) + 'px');

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

  function get_current_img_idx() {
    var spans = $(".content ul span");
    for (var i = 0; e = spans[i++];) {
      if ($(e).attr('src') == $("#image").attr('src')) {
        return i - 1;
      }
    }
    return -1;
  }

  function next() {
    window.console.log("next()");
    var i = get_current_img_idx();
    if (i < 0) {
      window.console.log("Not found!?");
      return;
    }

    var spans = $(".content ul span");
    i = (i == spans.length - 1) ? 0 : i + 1;
    window.console.log("Setting to " + i);
    $("#image").attr('src', $(spans[i]).attr('src'));
    get_all_comments();
  }

  function prev() {
    window.console.log("prev()");
    var i = get_current_img_idx();
    if (i < 0) {
      window.console.log("Not found!?");
      return;
    }

    var spans = $(".content ul span");
    i = (i == 0) ? spans.length - 1 : i - 1;
    window.console.log("Setting to " + i);
    $("#image").attr('src', $(spans[i]).attr('src'));
    get_all_comments();
  }

  return {
    init : function() {
      //compute_li_min_width();

      $('li').find('span').click(show_viewer);

      $('#overlay').click(kill_event);
      $('#exit-bg').click(hide_viewer);
      $("#x").click(hide_viewer);
      $('#submit').click(send_comment);
      $(window).resize(fit);
      $("#left").click(prev);
      $("#right").click(next);
    }
  };
})();

$(window).load(photos.init);
