# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

toggle_module = ->
        if $(this).is(':checked')
                $('#gpio').hide()
                $('#piface').show()
        else
                $('#gpio').show()
                $('#piface').hide()

$(document).on 'ready turbolinks:load', ->
        $('#pick_module').change toggle_module
