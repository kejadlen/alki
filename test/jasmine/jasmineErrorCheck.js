(function () {
    "use strict";
    var hasErrors = false;

    var errorHandler = function () {
        hasErrors = true;
    };

    window.addEventListener("error", errorHandler);

    window.jasmineErrorCheck = function () {
        window.removeEventListener("error", errorHandler);

        if (hasErrors) {
            $("#jasmine-load-error").show();
        } else {
            window.bootJasmine();
        }
    };
}());