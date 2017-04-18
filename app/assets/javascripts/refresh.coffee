# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

checker = ->
        setTimeout ( ->
                return unless $('.status.index').length > 0
                if !document.hidden and $('#sidenav-overlay').length == 0
                        Turbolinks.visit location.toString()
                else
                        checker()
                return
        ), 5000

$(document).on 'ready turbolinks:load', checker
