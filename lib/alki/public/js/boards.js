$(function(){
    $('.stop').click(function(){
        $.ajax({
            type: "DELETE",
            url: "webhook/" + this.id,
            success: function(){ location.reload(); }
        });
        return false;
    });

    $('.start').click(function(){
        $.post("webhook", { board_id: this.id }, function(){ location.reload(); });
        return false;
    });
});
