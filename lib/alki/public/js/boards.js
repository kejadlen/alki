(function () {
    window.Alki = {};

    Alki.boards = function ($root) {
        this._$root = $root;
    };

    Alki.boards.prototype.init = function () {
        this._$root.find('.stop').click(function () {
            $.ajax({
                type: "DELETE",
                url: "webhook/" + this.id,
                success: function () {
                    location.reload();
                }
            });
            return false;
        });

        this._$root.find('.start').click(function () {
            $.post("webhook", {board_id: this.id}, function () {
                location.reload();
            });
            return false;
        });
    };
}());