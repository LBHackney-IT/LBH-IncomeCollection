try { var moment = require('moment') } catch(err){}

window.EndDateCalculator = function EndDateCalculator (totalArrears, startDate, frequency, amount, initialPaymentAmount) {
  if (!totalArrears || !startDate || !frequency || !amount) return '';
  if (new Date(startDate) == 'Invalid Date') return '';
  if (initialPaymentAmount) totalArrears = parseFloat(totalArrears) - parseFloat(initialPaymentAmount);

  var numberOfInstalments = Math.ceil(parseFloat(totalArrears) / parseFloat(amount)) - 1;
  const frequencyOfPayment = (frequency.toLowerCase() == 'monthly') ? 'months' : 'weeks'

  if (frequency.toLowerCase() == 'fortnightly') numberOfInstalments = numberOfInstalments * 2;
  if (frequency.toLowerCase() == '4 weekly') numberOfInstalments = numberOfInstalments * 4;

  return moment(startDate).add(numberOfInstalments, frequencyOfPayment).format('D MMMM YYYY');
};
