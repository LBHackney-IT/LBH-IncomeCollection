var IncomeCollectionExport = (function() {
  function IncomeCollectionExport() {
    var _this = this;

    this.downloadCSV = function (patch) {
      showLoader();
      _this.getData(patch)
    };

    this.updateProgressBar = function (current_page, number_of_pages) {
      let percentage = ((current_page / number_of_pages) * 100).toFixed(2) + '%';
      $('.bar_filling').width(percentage);
      $('.bar_filling').text(percentage);
    };

    this.errorProgressBar = function () {
      $('.bar_filling').width('100%');
      $('.bar_filling').append(' - Failed, some data might be missing');
      $('.bar_filling').css("background-color","#be3a34");
    };

    this.getData = function (patch_code = null, page = 1, data_array = []) {
      Rails.ajax({
        url: "/worktray.json",
        type: "GET",
        async: false,
        data: $.param({
          patch_code: patch_code,
          page: page,
        }),
        retryLimit: 2,
        tryCount: 0,
        success: function(response) {
          _this.updateProgressBar(page , response.number_of_pages);
          if (response.number_of_pages != page) {
            _this.getData(patch_code, page+1, data_array.concat(response.tenancies));
          } else {
            _this.generateCSV(data_array.concat(response.tenancies));
          }
        },
        error: function(xhr, textStatus, errorThrown) {
          console.log([xhr, textStatus, errorThrown]);
          _this.errorProgressBar();
          _this.generateCSV(data_array);
        }
      });
    };

    this.generateCSV = function (data) {
      let checkboxes = $('[name="column_name"]');

      let columns = [];

      checkboxes.each(function () {
        if (this.checked == true) {
          columns.push(this.id)
        }
      });

      let csv = columns.join(',') + '\n';

      data.forEach(function(row) {
        let csv_row = columns.map(function (x) {
          return row[x]
        }).join();

        csv += csv_row + "\n";
      });

      let hiddenElement = document.createElement('a');
      hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
      hiddenElement.target = '_blank';
      hiddenElement.download = 'export.csv';
      hiddenElement.click();
      hideLoader();
    };

    return this;
  }

  return IncomeCollectionExport;
})();

$(document).on('turbolinks:load', function() {
  $( "#generate_button" ).click(function() {
    let patchCodeFromPage = $('#patch_code_filter').val();
    IncomeCollectionExport().downloadCSV(patchCodeFromPage);
  });
});



