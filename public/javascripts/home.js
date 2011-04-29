$(function(){
    // Setup AJAX
    $.ajaxSetup ({
        cache: false
    });

    // Setup caller function
    jQuery.fn.getPage = function (){
        var args = arguments[0] || {};

        // show the dialog
        $('#dialog_main').dialog("open");
        // Load the "home" page into dialog
        $.ajax({
            type: "GET",
            url: args.url,
            context: $('#dialog_main'),
            dataType: "html",
            success: function(data){
                $(this).html(data);
            }
        });
    }

    // Setup our dialog
    $('#dialog_main').dialog({
       autoOpen: true,
       width: 800,
       height:600,
       minWidth: 400,
       minHeight: 300
    });

    // Setup buttons
    $('#menu_home').button()
        .click(function(){
            $('dialog_main').getPage({url: '/news'});
        });

    $('#menu_signup').button()
        .click(function(){
            
        });
    $('#menu_signin').button({
        icons: { primary: "ui-icon-triangle-1-s" }
    });
    $('#menu_features').button();
    $('#menu_contact').button();
    $('#menu_about').button()
        .click(function(){
            $('dialog_main').getPage({url: '/about'});
        });

    $('#dialog_main').getPage({url: '/news'});
});