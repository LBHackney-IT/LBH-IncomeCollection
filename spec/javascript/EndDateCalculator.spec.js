import EndDateCalculator from '../../app/assets/javascripts/income_collection/EndDateCalculator.js'

describe('EndDateCalculator', function() {
  describe('when the params are invalid', function() {    
    it('returns empty string if any of the params are missing', function() {
      var totalArrears = '1000';
      var startDate = '2020-12-1';
      var frequency = '';
      var amount = '50';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount)).toEqual('')
    });

    it('returns empty string when the start date is invalid', function() {
      var totalArrears = '1000';
      var startDate = 'foo';
      var frequency = "Weekly";
      var amount = '50';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount)).toEqual('')
    });
  });

  describe('Weekly payments', function() {
    it('calcules end date when arrears paid in a single instalment', function() {
      var frequency = 'Weekly';
      var totalArrears = '20';
      var amount = '20';
      var startDate = '2020-12-01';
      var expectedEndDate = '1 December 2020';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount)).toEqual(expectedEndDate)
    });

    it('calculates end date when its exactly 2 weeks to complete', function() {
      var frequency = 'Weekly';
      var totalArrears = '100';
      var amount = '50';
      var startDate = '2020-12-01';
      var expectedEndDate = '8 December 2020';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount)).toEqual(expectedEndDate)
    });

    it('calculates end date when its exactly 3 weeks to complete', function() {
      var frequency = 'Weekly';
      var totalArrears = '150';
      var amount = '50';
      var startDate = '2020-12-01';
      var expectedEndDate = '15 December 2020';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount)).toEqual(expectedEndDate)
    });

    it('calculates end date when the last payment is less than the agreed amount', function() {
      var frequency = 'Weekly';
      var totalArrears = '120';
      var amount = '50';
      var startDate = '2020-12-01';
      var expectedEndDate = '15 December 2020';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount)).toEqual(expectedEndDate)
    });
  });

  describe('Monthly payments', function() {
    it('calcules end date when arrears paid in 2 instalment', function() {
      var frequency = 'Monthly';
      var totalArrears = '40';
      var amount = '20';
      var startDate = '2020-12-01';
      var expectedEndDate = '1 January 2021';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount)).toEqual(expectedEndDate)
    });
  }); 

  describe('Fortnightly payments', function() {
    it('calcules end date when arrears paid in 2 instalment', function() {
      var frequency = 'Fortnightly';
      var totalArrears = '40';
      var amount = '20';
      var startDate = '2020-12-01';
      var expectedEndDate = '15 December 2020';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount)).toEqual(expectedEndDate)
    });
  }); 

  describe('4 weekly payments', function() {
    it('calcules end date when arrears paid in 3 instalment', function() {
      var frequency = '4 weekly';
      var totalArrears = '50';
      var amount = '20';
      var startDate = '2020-12-01';
      var expectedEndDate = '26 January 2021';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount)).toEqual(expectedEndDate)
    });
  }); 

  describe('When there is an initial payment amount before or on the date of first instalment', function() {
    it('calcules end date when arrears paid in a single instalment', function() {
      var frequency = 'Weekly';
      var totalArrears = '50';
      var amount = '20';
      var startDate = '2020-12-01';
      var expectedEndDate = '1 December 2020';
      var initialPaymentAmount = '30';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount, initialPaymentAmount)).toEqual(expectedEndDate)
    });

    it('calculates end date when its exactly 2 instalments to complete', function() {
      var frequency = 'Weekly';
      var totalArrears = '70';
      var amount = '20';
      var startDate = '2020-12-01';
      var expectedEndDate = '8 December 2020';
      var initialPaymentAmount = '30';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount, initialPaymentAmount)).toEqual(expectedEndDate)
    });

    it('calculates end date when the last payment is less than the agreed amount', function() {
      var frequency = 'Weekly';
      var totalArrears = '80';
      var amount = '20';
      var startDate = '2020-12-01';
      var expectedEndDate = '15 December 2020';
      var initialPaymentAmount = '30';
      expect(window.EndDateCalculator(totalArrears, startDate, frequency, amount, initialPaymentAmount)).toEqual(expectedEndDate)
    });
  });
});


