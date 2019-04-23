function get_previews(pay_refs, template) {
  if (pay_refs.length != 0) {
    pay_refs = pay_refs.split(",");
    for (i in pay_refs) {
      ajax_preview(pay_refs[i], template);
    }
  }
};

function ajax_preview(pay_ref, template){
  Rails.ajax({
    url: "/letters/ajax_preview",
    type: "POST",
    data: $.param({
      template_id: template,
      pay_ref: pay_ref
    }),
    error: function(xhr,response){
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
