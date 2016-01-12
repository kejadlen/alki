/* jshint jasmine: true */
describe("Boards", function () {
    "use strict";

    var verifyAjax = function (expectedUrl, expectedMethod, expectedData) {
        var args;
        expect($.ajax).toHaveBeenCalled();
        args = $.ajax.calls.mostRecent().args[0];
        expect(args.type).toBe(expectedMethod);
        expect(args.url).toBe(expectedUrl);
        expect(args.data).toEqual(expectedData);
    };

    var checkReload = function (subject) {
        $.ajax.calls.mostRecent().args[0].success();
        expect(subject.reload).toHaveBeenCalled();
    };

    beforeEach(function () {
        spyOn($, "ajax");

        this.$root = $('<div><a class="start" id="foo"></a><a class="stop" id="bar"></a></div>');
        this.subject = new Alki.boards(this.$root);
        spyOn(this.subject, "reload");
        this.subject.init();
    });

    describe("When the user clicks Start", function () {
        beforeEach(function () {
            this.$root.find(".start").click();
        });

        it("should make a post request to webhook", function () {
            verifyAjax("webhook", "POST", {board_id: "foo"});
        });

        it("should reload when the call succeeds", function () {
            checkReload(this.subject);
        });
    });

    describe("When the user clicks Stop", function () {
        beforeEach(function () {
            this.$root.find(".stop").click();
        });

        it("should make an ajax request to webhook", function () {
            verifyAjax("webhook/bar", "DELETE");
        });

        it("should reload when the call succeeds", function () {
            checkReload(this.subject);
        });
    });
});