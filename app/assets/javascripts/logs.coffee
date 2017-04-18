$(document).on 'ready turbolinks:load', =>
        $('.datepicker').pickadate {
                selectMonths: true,
                selectYears: 15,
                format: 'yyyy-mm-dd'
        }
