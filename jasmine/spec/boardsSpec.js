/* jshint jasmine: true */
describe("Boards", function () {
    "use strict";
    beforeEach(function () {
        spyOn($, "post");
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
            var args;
            expect($.post).toHaveBeenCalled();
            args = $.post.calls.mostRecent().args;
            expect(args[0]).toBe("webhook");
            expect(args[1]).toEqual({board_id: "foo"});
        });

        describe("on a successful call to webhook", function () {
            beforeEach(function () {
                $.post.calls.mostRecent().args[2]();
            });

            it("should reload the page", function() {
                expect(this.subject.reload).toHaveBeenCalled();
            });
        });
    });

    describe("When the user clicks Stop", function () {
        beforeEach(function () {
            this.$root.find(".stop").click();
        });

        it("should make an ajax request to webhook", function () {
            var args;
            expect($.ajax).toHaveBeenCalled();
            args = $.ajax.calls.mostRecent().args[0];
            expect(args.type).toBe("DELETE");
            expect(args.url).toEqual("webhook/bar");
        });

        describe("on a successful call to webhook", function () {
            beforeEach(function () {
                $.ajax.calls.mostRecent().args[0].success();
            });

            it("should reload the page", function() {
                expect(this.subject.reload).toHaveBeenCalled();
            });
        });
    });
});