(function () {
    window.Alki = {};

    Alki.boards = function ($root) {
        this._$root = $root;
    };

    Alki.boards.prototype.init = function () {
        var that = this;

        this._$root.find('.stop').click(function () {
            $.ajax({
                type: "DELETE",
                url: "webhook/" + this.id,
                success: function () {
                    that.reload();
                }
            });
            return false;
        });

        this._$root.find('.start').click(function () {
            $.post("webhook", {board_id: this.id}, function () {
                that.reload();
            });
            return false;
        });
    };

    Alki.boards.prototype.reload = function () {
        location.reload();
    };
}());