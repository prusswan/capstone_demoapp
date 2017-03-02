(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.Role", RoleFactory);

  RoleFactory.$inject = ["$resource","spa-demo.config.APP_CONFIG"];
  function RoleFactory($resource, APP_CONFIG) {
    var service = $resource(APP_CONFIG.server_url + "/api/roles/:id",
        { id: '@id'},
        { update: {method:"PUT"} }
      );
    return service;
  }
})();
