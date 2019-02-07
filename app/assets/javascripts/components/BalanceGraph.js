window.BalanceGraph = function BalanceGraph (ctx, transactions) {
  var dates = transactions.map(function (transaction) {
    return new Date(transaction.date)
  });

  var balances = transactions.map(function (transaction) {
    return transaction.finalBalance
  });

  var chartOptions = createChartOptions(transactions);
  var data = {
    labels: dates,
    datasets: [{
      data: balances,
      lineTension: 0,
      borderColor: '#00634a',
      fill: false
    }]
  };

  return new Chart(ctx, {
    type: 'line',
    data: data,
    options: chartOptions
  })
};

function createChartOptions (transactions) {
  return {
    responsive: true,
    maintainAspectRatio: false,
    legend: {
      display: false
    },
    tooltips: {
      displayColors: false,
      intersect: false,
      mode: 'nearest',
      callbacks: {
        title: function (tooltips) {
          var transaction = transactions[tooltips[0].index];
          return transaction.description
        },
        label: function (tooltip) {
          var transaction = transactions[tooltip.index];
          return transaction.displayValue
        }
      }
    },
    scales: {
      xAxes: [{
        display: true,
        type: 'time',
        time: {
          unit: 'month'
        },
        scaleLabel: {
          display: true,
          labelString: 'Time'
        }
      }],
      yAxes: [{
        display: true,
        position: 'right',
        scaleLabel: {
          display: true,
          labelString: 'Balance'
        },
        ticks: {
          beginAtZero: true
        }
      }]
    }
  }
}
