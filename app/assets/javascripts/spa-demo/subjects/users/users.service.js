(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.User", UserFactory);

  UserFactory.$inject = ["$resource","spa-demo.config.APP_CONFIG"];
  function UserFactory($resource, APP_CONFIG) {
    var service = $resource(APP_CONFIG.server_url + "/api/users/:id",
        { id: '@id'},
        { update: {method:"PUT"} }
      );
    return service;
  }
})();
