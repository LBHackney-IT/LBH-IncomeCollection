// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.

// Disabled as activestorage is not installed in this project
// require activestorage

//= require rails-ujs
//= require turbolinks
//= require_tree .



function send_all(list_of_refs, template_id) {

  Rails.ajax({
    url: "/letters/preview.js",
    type: "POST",
    data: "first_name=dfhdfjhdfjhjhfdjhfdy",
    success: function(data) {
      console.log(data);
      console.log( "fart!" );

    }
  });


  // fetch('/letters/preview.js', {
  //   method: 'post',
  //   body: JSON.stringify({first_name: "Ricky", last_name: "Bobby"}),
  //   headers: {
  //     'Content-Type': 'application/json',
  //     'X-CSRF-Token': Rails.csrfToken()
  //   },
  //   credentials: 'same-origin'
  // }).then(function(response) {
  //   return response.json();
  // }).then(function(data) {
  //   console.log(data);
  // });




  // $.ajax({
  //   url: '/letters/preview.js',
  //   type: 'post',
  //   dataType: 'json',
  //   contentType: 'application/json',
  //   success: function (data) {
  //     $('#target').html(data.msg);
  //     console.log('wowowo') ;
  //
  //   },
  //   complete: function (data) {
  //     console.log('wowowowww222ooo') ;
  //
  //   },
  //   data: JSON.stringify({
  //     payment_ref: 'js',
  //     authenticity_token:"p2J+yENid/4LbF4WhdSeA/Y/70KgIclXIAn051dG8zAlSj2Qg3ePKJGTh+h71+liQj2QAIpTCa1fn7+iQyZl8Q==",
  //     template_id: 'letter_1_in_arrears_FH_agreed_template'
  //   })
  // }).done(function() {
  //   console.log('wooo') ;
  //   $( this ).append( "done" );
  // });
}

// $.ajax({
//   url: "https://fiddle.jshell.net/favicon.png",
//   beforeSend: function( xhr ) {
//     xhr.overrideMimeType( "text/plain; charset=x-user-defined" );
//   }
// })
//   .done(function( data ) {
//     if ( console && console.log ) {
//       console.log( "Sample of data:", data.slice( 0, 100 ) );
//     }
//   });

function s_table(one, two)
{
  $("#successful_table").append("<tr><td>"+one+"</td><td>"+two+"</td></tr>");
}
// letters = {
//   init: function(listOfRefs) {
//     this.paymentRef = listOfRefs
//   },
//   // name: 'Chris',
//   // age: 38,
//   // greeting: function() {
//   //   alert('Hi! I\'m ' + this.name + '.');
//   // }
// };
