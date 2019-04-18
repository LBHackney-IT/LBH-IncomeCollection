
function submit_send_all(){
  var letter_data=$('.letter').data()

  $.each( letter_data, function( key, value ) {
    if(key != 'uuid'){
      next();
    }
    console.log( key + ": " + value );
    var letter = $('.letter').data(key, value)
    letter.find(".send_letter_button").click()
  });
}

