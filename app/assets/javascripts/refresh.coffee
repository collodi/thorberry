# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

counter = 0
checker = ->
        counter++
        setTimeout ( ->
                counter--
                return unless $('.status.index').length > 0
                if counter > 0
                        return
                else if !document.hidden and $('#sidenav-overlay').length == 0
                        Turbolinks.visit location.toString()
                else
                        checker()
                return
        ), 10000

$(document).on 'ready turbolinks:load', checker
