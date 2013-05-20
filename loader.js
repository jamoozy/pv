var loader = (function() {
  function loadContent() {
    populateContent('');
  }

  function populateContent(json) {
    //var obj = eval(json);
    var entries = [
      { 'title' : 'Wedding',
        'thumbnail' : 'Wedding/thumb.jpg',
        'images' : [
          'Wedding/000.jpg',
          'Wedding/001.jpg',
          'Wedding/002.jpg',
          'Wedding/003.jpg',
          'Wedding/004.jpg',
        ]
      }
    ];

    window.console.log('going for: ' + entries);

    var html = '';
    for (var i = 0; i < entries.length; i++) {
      var e = entries[i];
      html += '<li><img src="';
      html += e['thumbnail'];
      html += '">';
      html += e['title'];
      html += '<span class="images-list">';
      html += e['images'];
      html += '</span></li>';
    }

    window.console.log('html: ' + html);
    $('.content').html('<ul>' + html + '</ul>');
    window.console.log('Set to ' + $('.content'));
  }

  return {
    init : function() {
      loadContent();
    }
  };
})();

$(window).on('load', loader.init());
