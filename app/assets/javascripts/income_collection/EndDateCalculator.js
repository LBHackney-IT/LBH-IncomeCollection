try { var moment = require('moment') } catch(err){}

window.EndDateCalculator = function EndDateCalculator (totalArrears, startDate, frequency, amount) {
  if (!totalArrears || !startDate || !frequency || !amount) return '';
  if (new Date(startDate) == 'Invalid Date') return '';

  var numberOfInstalments = Math.ceil(parseFloat(totalArrears) / parseFloat(amount)) - 1;
  const frequencyOfPayment = (frequency == 'Monthly') ? 'months' : 'weeks'

  if (frequency == 'Fortnightly') numberOfInstalments = numberOfInstalments * 2;
  if (frequency == '4 weekly') numberOfInstalments = numberOfInstalments * 4;

  return moment(startDate).add(numberOfInstalments, frequencyOfPayment).format('D MMMM YYYY');
};
