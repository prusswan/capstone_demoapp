(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.ThingRoles", ThingRoles);

  ThingRoles.$inject = ["$resource", "spa-demo.config.APP_CONFIG"];
  function ThingRoles($resource, APP_CONFIG) {
    return $resource(APP_CONFIG.server_url + "/api/things/:thing_id/roles/:role_name/:user_id",
      { thing_id: '@thing_id',
        role_name: '@role_name',
        user_id: '@id'},
      {
        update: {method:"PUT"},
        // members: {method: 'GET', isArray: true, url: APP_CONFIG.server_url + "/api/things/:thing_id/roles/members"},
        // organizers: {method: 'GET', isArray: true, url: APP_CONFIG.server_url + "/api/things/:thing_id/roles/organizers"}
      });
  }

})();
