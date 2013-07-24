// Copyright (c) 2013 Andrew "Jamoozy" Correa S.,
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

var upload = (function() {
  // Disables the "Upload!" button.
  function disable_upload_button() {
    $(':button').attr('disabled', 'disabled');
  }

  // Enables the "Upload!" button.
  function enable_upload_button() {
    $(':button').removeAttr('disabled');
  }

  // Sets the status of the status dive and slides it up when done.
  function set_status(stat) {
    $('#status').html(stat).show().delay(5000).slideUp(1000);
  }

  return {
    init : function() {
      window.console.log("loaded");

      $(':file').change(function(){
        if ($(this.files).size() > 0) {
          enable_upload_button();
        } else {
          disable_upload_button();
        }
      });

      $(':button').click(function() {
        var formData = new FormData($('form')[0]);
        $.ajax({
          url: 'upload.rb',
          type: 'POST',
          xhr: function() {
            var myXhr = $.ajaxSettings.xhr();

            if (myXhr.upload) {
              // for handling the progress of the upload
              myXhr.upload.addEventListener('progress', function(e) {
                if(e.lengthComputable){
                  $('progress').attr(
                    { value: e.loaded, max: e.total });
                }
              }, false);
            }
            return myXhr;
          },

          // Ajax events
          beforeSend: function(b) {
            $('progress').show();
          },
          success: function(dat, stat, jqXHR) {
            $('progress').hide();
            $(":file").prop('value', '');
            disable_upload_button();
            eval('var obj = ' + dat);
            set_status(obj.status);
          },
          error: function(jqXHR, st, err) {
            $('progress').hide();
            window.console.log('Error: ' + st);
          },
          complete: function(jqXHR, st) {
          },

          // Form data
          data: formData,

          // Options to tell JQuery not to process data or
          // worry about content-type
          cache: false,
          contentType: false,
          processData: false
        });
      });

      // Start jQuery Asynchronous Image Loading.
//      $('img.lazy').jail({effect:'fadeIn'});
    }
  };
})();

$(window).load(upload.init);
