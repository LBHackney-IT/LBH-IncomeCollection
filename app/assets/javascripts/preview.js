$( document ).on('turbolinks:load', function() {
  if ($('.letters').length > 0 ){
    var pay_refs = $(".letters").data('uuids')
    var template_id = $(".letters").data('template_id')
    get_previews(pay_refs,template_id)
  }
});

function get_previews(pay_refs, template_id) {
  if (pay_refs.length != 0) {
    showLoader()
    pay_refs = pay_refs.split(",");
    max = pay_refs.length
    for (i in pay_refs) {
      ajax_preview(pay_refs[i], template_id, max);
    }
  }
};

var countPreviews = 0
function handlePreview(){
  countPreviews++
  if(countPreviews >= max) {
    hideLoader()
  }
}

function ajax_preview(pay_ref, template_id, max){
  Rails.ajax({
    url: "/letters/ajax_preview",
    type: "POST",
    async: false,
    data: $.param({
      template_id: template_id,
      pay_ref: pay_ref
    }),
    complete: function(){
      handlePreview()
    },
    error: function(xhr,response){
      handlePreview()
      increment_fail_counter()
      $("#errors_table").append("<tr><td>"+pay_ref+"</td><td colspan='2'>"+response+"</td></tr>");
    }
  });
};

function increment_success_counter() {
  successful_counter = $('#successful_count')
  successful_counter.text(1 + parseInt(successful_counter.text()))
};

function increment_fail_counter() {
  fail_counter = $('#failed_count')
  fail_counter.text(1 + parseInt(fail_counter.text()))
};

function showLoader() {
  $('.loader').fadeIn(100)
}

function hideLoader() {
  $('.loader').fadeOut(100)
}


function visibleSendButtons(){
  return ($('#successful_table .letter[data-uuid]').length >= 1)
}

async function submit_send_all_letters(e){
  var retVal = confirm('Are you sure you want to send all the letters listed here?')
  if (retVal != true){ return false }

 var $all_button = $(e.target)
 $all_button.attr('disabled', true)

 $('#successful_table .letter[data-uuid] .send_letter_button').each(function() {
    $(this).click()
  })

 $all_button.hide()
}



