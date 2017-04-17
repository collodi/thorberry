# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.datepicker').pickadate({
	selectMonths: true,
	selectYears: 15
});

checker = ->
        setTimeout ( ->
                if !document.hidden then Turbolinks.visit location.toString() else checker()
                return
        ), 5000

$(document).on 'ready turbolinks:load', checker
