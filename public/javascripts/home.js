$(function(){
    $.ajaxSetup ({
        cache: false
    });

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
            // Load the "home" page into dialog
            $.ajax({
                type: "GET",
                url: "/news",
                context: $('#dialog_main'),
                dataType: "html",
                success: function(data){
                    $(this).html(data);
                }
            });
        });

    $('#menu_signup').button()
        .click(function(){
            $('#dialog_main').dialog("open");
        });
    $('#menu_signin').button({
        icons: { primary: "ui-icon-triangle-1-s" }
    });
    $('#menu_features').button();
    $('#menu_contact').button();
    $('#menu_about').button();

});