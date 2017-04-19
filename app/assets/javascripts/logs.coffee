$(document).on 'ready turbolinks:load', =>
        $('.datepicker').pickadate {
                selectMonths: true,
                selectYears: 15,
                format: 'yyyy-mm-dd'
        }

        $('.log-submit').click ->
                $('#log-form').attr 'action', $(this).attr("data-action")
