//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require document_meta
//= require organization

var batch_token = "";

$(function(){
  if($(".active-org").length) {
    $('.nav-sidebar').scrollTop($(".active-org").offset().top-254)
  }

  $("button#manual_expire_lock").on("click",function(){
    updateLock(true);
    setTimeout(function () {
      location.reload();
    }, 500);
  });

  $('#republish').on("hidden.bs.modal", function(){
    cancel("true");
    updateLock(true);
  });

  $('#org_filter :input').on('keyup change', function(){
    var target = $(this).closest('#org_filter').next('ul');
    var orgFilter = new RegExp($(this).val(), 'i');
    var orgElements = $('li', target);

    var matched = $.grep(orgElements, function(item){
      return $(item).text().search(orgFilter) >= 0;
    });

    $(matched).show();
    orgElements.not(matched).hide();
  }).trigger('change');
  
  $('#toggleChecked').on('click', function() {
    var isChecked = $('#salsaDocuments :checkbox:first').is(':checked');

    if(isChecked) {
      $('#salsaDocuments :checkbox').prop('checked', false);
    } else {
      $('#salsaDocuments :checkbox').prop('checked', true);
    }

    return false;
  });

  $('#republish').on("shown.bs.modal", function(e){
    var batch_token = $('#batch_token').html();
    var sources = [];
    var urls = $.parseJSON($('#republish_ids').html());
    for(var i = 0; i < urls.length; i++) {
      sources.push(urls[i] + "?batch_token=" + batch_token);
    }

    updateProgress(0, 0, sources);
    var counter = 0;
    var errors = 0;
    republish(batch_token, sources, counter, errors);
  });
});

function updateLock(expire) {
  if(!expire) {
    expire = false;
  }
  slug = $('#update_lock_url').html();
  $.get(slug + "?expire=" + expire);

}


function republish(token, sources, counter, errors) {
  cancel("false");
  updateLock(false);

  var increment = 100 / sources.length;
  var iframe = document.getElementById('republish_iframe');

  $(iframe).css('display', 'none');
  $('.errors').html('<p>Errors: ' + errors + "</p>");

  iframe.onload = function() {
    var jquery = iframe.contentWindow.jQuery;
    var a = jquery('#tb_share');

    a.off('ajax:beforeSend');

    a.on('ajax:beforeSend', function(event, xhr, settings) {

      if($('body').hasClass('disable-save')) {
        xhr.abort();
        return false;
      }
      
      settings.data = jquery('#page-data').html();

      var document_version = jquery('[data-document-version]').attr('data-document-version');
      settings.url = settings.url + '&document_version=' + document_version + "&batch_token=" + token;

      run_document_meta_in_iframe(settings)

      // should be save to LMS...
      var tb_send_canvas = jquery('#tb_send_canvas');
      if ( tb_send_canvas.is(':visible') ) {
        tb_send_canvas.attr("href", tb_send_canvas.attr("href") + "&batch_token=" + token )
        jquery('#tb_send_canvas').trigger('click')
      } 
      // if($('#tb_send_canvas:visible')).trigger('click');
    });

    a.on('ajax:success', function(event,data) {
      if(data.status != 'ok') {
        errors++;
      }

      counter++;
      updateProgress(increment, counter, sources);
      if(counter >= sources.length || cancel()) {
        updateLock(true);
        if (errors > 0) {
          $('.modal-body').append('<div class="alert alert-danger" role="alert"><strong>Errors!</strong> Please refresh the page to rerun any missing documents. If the problem persists, please contact your admin.</div>');
        } else {
          $('.modal-body').append('<div class="alert alert-success" role="alert"><strong>Success!</strong> Document republishing has successfully completed.</div>');
        }
        return;
      }

      republish(token, sources, counter, errors);
    });

    a.trigger('click.rails');

  }
  iframe.src = sources[counter];
}

function cancel(bool_string) {
  if (bool_string) {
    $("button#close_republish").attr("data-cancel", bool_string);
    return bool_string == "true"
  }
  return $("button#close_republish").attr("data-cancel") == "true";
}

function updateProgress(increment, counter, sources) {
  var progressBar = $('.progress-bar');
  var progress = parseFloat($('.progress-bar').attr('aria-valuenow'));
  var newProgress = increment * counter;
  if(progress == sources){
    newProgress = 0;
  }
  progressBar.attr('aria-valuenow', counter);
  progressBar.attr('style', 'width: ' + newProgress + '%');
  progressBar.html(counter + ' of ' + sources.length);
}
