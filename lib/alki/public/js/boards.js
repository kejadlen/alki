(function () {
    "use strict";
    window.Alki = {};

    Alki.boards = function ($root) {
        this._$root = $root;
    };

    Alki.boards.prototype.init = function () {
        var that = this;

        this._$root.find('.stop').click(function (event) {
            event.preventDefault();
            $.ajax({
                type: "DELETE",
                url: "webhook/" + event.target.id,
                success: function () {
                    that.reload();
                }
            });
        });

        this._$root.find('.start').click(function (event) {
            event.preventDefault();
            $.post("webhook", {board_id: event.target.id}, function () {
                that.reload();
            });
        });
    };

    Alki.boards.prototype.reload = function () {
        location.reload();
    };
}());