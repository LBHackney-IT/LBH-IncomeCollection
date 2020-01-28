var IncomeCollectionPreview = (function() {
  function IncomeCollectionPreview(element) {
    var _this = this;

    this.element = element;
    this.numberOfTenancies = 0;
    this.countPreviews = 0;

    this._bindEvents = function() {
      _this.element.find('.button.send-all').on('click', function(evt) {
        _this.handleSendAllButtonClicked(evt);
      });
    };

    this.handleSendAllButtonClicked = function(evt) {
      var retVal = confirm('Are you sure you want to send all the letters listed here?');

      if (retVal !== true) {
        return false;
      }

      var $all_button = $(evt.target);
      $all_button.attr('disabled', true);

      $('#successful_table .letter[data-uuid] .send_letter_button:visible').each(function() {
        $(this).click();
      });

      $all_button.hide();
    };

    this.getPreviews = function() {
      var tenancyRefs = _this.element.data('uuids');
      var templateId = _this.element.data('templateId');

      if (tenancyRefs.length > 0) {
        _this.numberOfTenancies = tenancyRefs.length;
        _this.showLoader();

        for (var i in tenancyRefs) {
          _this.loadPreview(tenancyRefs[i], templateId);
        }
      }
    };


    this.updatePreviewCounter = function() {
      _this.countPreviews++;

      if (_this.countPreviews >= _this.numberOfTenancies) {
        _this.hideLoader();
      }
    };

    this.showLoader = function () {
      $('.loader').fadeIn(100);
    };

    this.hideLoader = function() {
      $('.loader').fadeOut(100);
    };

    this.loadPreview = function(tenancyRef, templateId) {
      window.Rails.ajax({
        url: _this.element.data('url'),
        type: "POST",
        async: false,
        data: $.param({
          template_id: templateId,
          tenancy_ref: tenancyRef,
          format: 'js'
        }),
        retryLimit: 2,
        tryCount: 0,
        success: function() {
          _this.updatePreviewCounter();
        },
        error: function(jqxhr, textStatus, errorThrown){
          if (errorThrown.status === 500) {
            this.tryCount++;
            // retry
            if (this.tryCount <= this.retryLimit) {
              window.Rails.ajax(this);
              return;
            } else {
              console.log(textStatus)
              this.handleError(tenancyRef, textStatus);
            }
            return;
          } else {
            this.handleError(tenancyRef, textStatus);
          }
        }
      });
    };

    this.handleError = function(tenancyRef, textStatus){
      _this.handlePreview();
      _this.increment_fail_counter();
      $("#errors_table").append("<tr><td>"+tenancyRef+"</td><td colspan='2'>"+textStatus+"</td></tr>");
    };

    this.incrementSuccessCounter = function() {
      var successful_counter = $('#successful_count');
      successful_counter.text(1 + parseInt(successful_counter.text()));
    };

    this.incrementFailCounter = function() {
      var fail_counter = $('#failed_count');
      fail_counter.text(1 + parseInt(fail_counter.text()));
    };

    this._bindEvents();

    return this;
  }

  return IncomeCollectionPreview;
})();



$(document).on('turbolinks:load', function() {
  if ($('.letters[data-income-collection]').length > 0 ) {
    var incomeCollectionPreview = new IncomeCollectionPreview($('.letters[data-income-collection]'));
    incomeCollectionPreview.getPreviews();
  }
});
