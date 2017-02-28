(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdThingEditor", {
      templateUrl: thingEditorTemplateUrl,
      controller: ThingEditorController,
      bindings: {
        authz: "<"
      },
      require: {
        thingsAuthz: "^sdThingsAuthz"
      }
    })
    .component("sdThingSelector", {
      templateUrl: thingSelectorTemplateUrl,
      controller: ThingSelectorController,
      bindings: {
        authz: "<"
      }
    })
    ;


  thingEditorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function thingEditorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.thing_editor_html;
  }
  thingSelectorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function thingSelectorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.thing_selector_html;
  }

  ThingEditorController.$inject = ["$scope","$q",
                                   "$state","$stateParams",
                                   "spa-demo.authz.Authz",
                                   "spa-demo.subjects.User",
                                   "spa-demo.subjects.Thing",
                                   "spa-demo.subjects.ThingRoles",
                                   "spa-demo.subjects.ThingImage"];
  function ThingEditorController($scope, $q, $state, $stateParams,
                                 Authz, User, Thing, ThingRoles, ThingImage) {
    var vm=this;
    vm.create = create;
    vm.clear  = clear;
    vm.update  = update;
    vm.remove  = remove;
    vm.haveDirtyLinks = haveDirtyLinks;
    vm.updateImageLinks = updateImageLinks;
    vm.addMember = addMember;
    vm.addOrganizer = addOrganizer;

    vm.$onInit = function() {
      console.log("ThingEditorController",$scope);
      $scope.$watch(function(){ return Authz.getAuthorizedUserId(); },
                    function(){
                      if ($stateParams.id) {
                        reload($stateParams.id);
                      } else {
                        newResource();
                      }
                    });
    }

    return;
    //////////////
    function newResource() {
      vm.item = new Thing();
      vm.thingsAuthz.newItem(vm.item);
      return vm.item;
    }

    function reload(thingId) {
      var itemId = thingId ? thingId : vm.item.id;
      console.log("re/loading thing", itemId);
      vm.images = ThingImage.query({thing_id:itemId});
      vm.members = ThingRoles.query({thing_id:itemId, role_name:'member'});
      vm.organizers = ThingRoles.query({thing_id:itemId, role_name:'organizer'});
      vm.users = User.query();

      vm.item = Thing.get({id:itemId});
      vm.thingsAuthz.newItem(vm.item);
      vm.images.$promise.then(
        function(){
          angular.forEach(vm.images, function(ti){
            ti.originalPriority = ti.priority;
          });
        });
      $q.all([vm.item.$promise,vm.images.$promise]).catch(handleError);
    }
    function haveDirtyLinks() {
      for (var i=0; vm.images && i<vm.images.length; i++) {
        var ti=vm.images[i];
        if (ti.toRemove || ti.originalPriority != ti.priority) {
          return true;
        }
      }
      return false;
    }

    function create() {
      vm.item.errors = null;
      vm.item.$save().then(
        function(){
          console.log("thing created", vm.item);
          $state.go(".",{id:vm.item.id});
        },
        handleError);
    }

    function clear() {
      newResource();
      $state.go(".",{id: null});
    }

    function update() {
      vm.item.errors = null;
      var update=vm.item.$update();
      updateImageLinks(update);
    }
    function updateImageLinks(promise) {
      console.log("updating links to images");
      var promises = [];
      if (promise) { promises.push(promise); }
      angular.forEach(vm.images, function(ti){
        if (ti.toRemove) {
          promises.push(ti.$remove());
        } else if (ti.originalPriority != ti.priority) {
          promises.push(ti.$update());
        }
      });

      console.log("waiting for promises", promises);
      $q.all(promises).then(
        function(response){
          console.log("promise.all response", response);
          //update button will be disabled when not $dirty
          $scope.thingform.$setPristine();
          reload();
        },
        handleError);
    }

    function remove() {
      vm.item.$remove().then(
        function(){
          console.log("thing.removed", vm.item);
          clear();
        },
        handleError);
    }

    function addMember() {
      console.log("add member", vm.selectUserId);
      ThingRoles.save({thing_id: vm.item.id, user_id: vm.selectUserId, role_name: 'member'}).$promise.then(
        function(response){
          // reload(vm.item.id);
          // vm.members = ThingRoles.query({thing_id:vm.item.id, role_name:'member'});
          vm.members.push(response);
        },
        handleError);
    }
    function addOrganizer() {
      console.log("add organizer", vm.selectUserId);
      ThingRoles.save({thing_id: vm.item.id, user_id: vm.selectUserId, role_name: 'organizer'}).$promise.then(
        function(response){
          // console.log(response);
          vm.organizers.push(response);
        },
        handleError);
    }

    function handleError(response) {
      console.log("error", response);
      if (response.data) {
        vm.item["errors"]=response.data.errors;
      }
      if (!vm.item.errors) {
        vm.item["errors"]={}
        vm.item["errors"]["full_messages"]=[response];
      }
      $scope.thingform.$setPristine();
    }
  }

  ThingSelectorController.$inject = ["$scope",
                                     "$stateParams",
                                     "spa-demo.authz.Authz",
                                     "spa-demo.subjects.Thing"];
  function ThingSelectorController($scope, $stateParams, Authz, Thing) {
    var vm=this;

    vm.$onInit = function() {
      console.log("ThingSelectorController",$scope);
      $scope.$watch(function(){ return Authz.getAuthorizedUserId(); },
                    function(){
                      if (!$stateParams.id) {
                        vm.items = Thing.query();
                      }
                    });
    }
    return;
    //////////////
  }

})();
