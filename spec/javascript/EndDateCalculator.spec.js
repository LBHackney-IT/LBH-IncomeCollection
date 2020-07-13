import EndDateCalculator from '../../app/assets/javascripts/income_collection/EndDateCalculator.js'

test('returns an empty string', () => {
  expect(window.EndDateCalculator()).toEqual('FOOO')
})
