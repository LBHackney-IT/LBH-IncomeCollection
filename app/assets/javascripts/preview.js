$(document).on("turbolinks:load", function() {
  if ($(".letters").length > 0) {
    var pay_refs = $(".letters").data("uuids");
    var template_id = $(".letters").data("template_id");
    get_previews(pay_refs, template_id);
  }
});

function get_previews(pay_refs, template_id) {
  if (pay_refs.length != 0) {
    showLoader();
    max = pay_refs.length;
    for (i in pay_refs) {
      ajax_preview(pay_refs[i], template_id, max);
    }
  }
}

var countPreviews = 0;
function handlePreview() {
  countPreviews++;
  if (countPreviews >= max) {
    hideLoader();
  }
}

function handleError(pay_ref, textStatus) {
  handlePreview();
  increment_fail_counter();
  $("#errors_table").append(
    "<tr><td>" + pay_ref + "</td><td colspan='2'>" + textStatus + "</td></tr>"
  );
}

function ajax_preview(pay_ref, template_id, max) {
  Rails.ajax({
    url: "/leasehold/letters/ajax_preview",
    type: "POST",
    async: false,
    data: $.param({
      template_id: template_id,
      pay_ref: pay_ref
    }),
    retryLimit: 2,
    tryCount: 0,
    success: function() {
      handlePreview();
    },
    error: function(jqxhr, textStatus, errorThrown) {
      if (errorThrown.status == 500) {
        this.tryCount++;
        // retry
        if (this.tryCount <= this.retryLimit) {
          Rails.ajax(this);
          return;
        } else {
          console.log(textStatus);
          handleError(pay_ref, textStatus);
        }
        return;
      } else {
        handleError(pay_ref, textStatus);
      }
    }
  });
}

function increment_success_counter() {
  successful_counter = $("#successful_count");
  successful_counter.text(1 + parseInt(successful_counter.text()));
}

function increment_fail_counter() {
  fail_counter = $("#failed_count");
  fail_counter.text(1 + parseInt(fail_counter.text()));
}

function showLoader() {
  $(".loader").fadeIn(100);
}

function hideLoader() {
  $(".loader").fadeOut(100);
}

function visibleSendButtons() {
  return $("#successful_table .letter[data-uuid]").length >= 1;
}

function hideDownloadButton(event) {
  $(event.target).hide();
}
async function submit_send_all_letters(e) {
  var retVal = confirm(
    "Are you sure you want to send all the letters listed here?"
  );
  if (retVal != true) {
    return false;
  }

  var $all_button = $(e.target);
  $all_button.attr("disabled", true);

  $("#successful_table .letter[data-uuid] .send_letter_button").each(
    function() {
      $(this).click();
    }
  );

  $all_button.hide();
}
