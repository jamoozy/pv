var loader = (function() {
  function loadContent() {
    populateContent('');
  }

  function populateContent(json) {
    //var obj = eval(json);
    var entries = [
      { 'title' : 'Engagement',
        'thumbnail' : 'engagement/thumb.jpg',
        'images' : [
          ['IMG_0464 copy-thumb.jpg',     'IMG_0464 copy.jpg'],
          ['IMG_0475 copy-thumb.jpg',     'IMG_0475 copy.jpg'],
          ['IMG_0485 copy-thumb.jpg',     'IMG_0485 copy.jpg'],
          ['IMG_0500 copy-thumb.jpg',     'IMG_0500 copy.jpg'],
          ['IMG_0504 copy-thumb.jpg',     'IMG_0504 copy.jpg'],
          ['IMG_0508 copy-thumb.jpg',     'IMG_0508 copy.jpg'],
          ['IMG_0525 copy-thumb.jpg',     'IMG_0525 copy.jpg'],
          ['IMG_0550 copy-thumb.jpg',     'IMG_0550 copy.jpg'],
          ['IMG_0554 copy-thumb.jpg',     'IMG_0554 copy.jpg'],
          ['IMG_0563 copy-thumb.jpg',     'IMG_0563 copy.jpg'],
          ['IMG_0598 copy-thumb.jpg',     'IMG_0598 copy.jpg'],
          ['IMG_0601 copy-thumb.jpg',     'IMG_0601 copy.jpg'],
          ['IMG_0618 copy copy-thumb.jpg','IMG_0618 copy copy.jpg'],
          ['IMG_0618 copy-thumb.jpg',     'IMG_0618 copy.jpg'],
          ['IMG_0630 copy-thumb.jpg',     'IMG_0630 copy.jpg'],
          ['IMG_0639 copy-thumb.jpg',     'IMG_0639 copy.jpg'],
          ['IMG_0648 copy-thumb.jpg',     'IMG_0648 copy.jpg'],
          ['IMG_0652 copy-thumb.jpg',     'IMG_0652 copy.jpg'],
          ['IMG_0666 copy copy-thumb.jpg','IMG_0666 copy copy.jpg'],
          ['IMG_0666 copy-thumb.jpg',     'IMG_0666 copy.jpg'],
          ['IMG_0670 copy-thumb.jpg',     'IMG_0670 copy.jpg'],
          ['IMG_0683 copy-thumb.jpg',     'IMG_0683 copy.jpg'],
          ['IMG_0685 copy-thumb.jpg',     'IMG_0685 copy.jpg'],
          ['IMG_0690 copy-thumb.jpg',     'IMG_0690 copy.jpg'],
          ['IMG_0692 copy-thumb.jpg',     'IMG_0692 copy.jpg'],
          ['IMG_0712 copy copy-thumb.jpg','IMG_0712 copy copy.jpg'],
          ['IMG_0712 copy-thumb.jpg',     'IMG_0712 copy.jpg'],
          ['IMG_0732 copy copy-thumb.jpg','IMG_0732 copy copy.jpg'],
          ['IMG_0732 copy-thumb.jpg',     'IMG_0732 copy.jpg'],
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
    var content = $('.content');
    content.html('<ul>' + html + '</ul>');
    window.console.log('Set to ' + content.size() + '-length object.');
  }

  return {
    init : function() {
      loadContent();
    }
  };
})();

$(window).load(loader.init());

