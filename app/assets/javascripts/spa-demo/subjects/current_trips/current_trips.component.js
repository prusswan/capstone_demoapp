(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdCurrentTrips", {
      templateUrl: tripsTemplateUrl,
      controller: CurrentTripsController,
    })
    .component("sdCurrentTripsMap", {
      template: "<div id='map'></div>",
      controller: CurrentTripsMapController,
      bindings: {
        zoom: "@"
      }
    });

  tripsTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function tripsTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.current_trips_html;
  }

  CurrentTripsController.$inject = ["$scope",
                                     "spa-demo.subjects.currentTrips"];
  function CurrentTripsController($scope,currentTrips) {
    var vm=this;
    vm.thingClicked = thingClicked;
    vm.tripClicked = tripClicked;
    vm.isCurrentThing = currentTrips.isCurrentThingIndex;
    vm.isCurrentTrip = currentTrips.isCurrentTripIndex;

    vm.$onInit = function() {
      console.log("CurrentTripsController",$scope);
    }
    vm.$postLink = function() {
      $scope.$watch(
        function() { return currentTrips.getTrips(); },
        function(trips) { vm.trips = trips; }
      );
    }
    return;
    //////////////
    function thingClicked(index) {
      currentTrips.setCurrentThing(index);
    }
    function tripClicked(index) {
      currentTrips.setCurrentTrip(index);
    }

  }

  CurrentTripsMapController.$inject = ["$scope", "$q", "$element",
                                          "spa-demo.geoloc.currentOrigin",
                                          "spa-demo.geoloc.myLocation",
                                          "spa-demo.geoloc.Map",
                                          "spa-demo.subjects.currentTrips",
                                          "spa-demo.config.APP_CONFIG"];
  function CurrentTripsMapController($scope, $q, $element,
                                        currentOrigin, myLocation, Map, currentTrips,
                                        APP_CONFIG) {
    var vm=this;

    vm.$onInit = function() {
      console.log("CurrentTripsMapController",$scope);
    }
    vm.$postLink = function() {
      var element = $element.find('div')[0];
      getLocation().then(
        function(location){
          vm.location = location;
          initializeMap(element, location.position);
        });

      $scope.$watch(
        function(){ return currentTrips.getImages(); },
        function(images) {
          vm.images = images;
          displaySubjects();
        });
      $scope.$watch(
        function(){ return currentTrips.getTrips(); },
        function(trips) {
          vm.trips = trips;
          // displayTrip();
        });

      $scope.$watch(
        function(){ return currentTrips.getCurrentImage(); },
        function(link) {
          if (link) {
            vm.setActiveMarker(link.thing_id, link.image_id);
          } else {
            vm.setActiveMarker(null,null);
          }
        });

      $scope.$watch(
        function(){ return currentTrips.getCurrentTrip(); },
        function(link) {
          displayTrip(link);
          if (link) {
            vm.setActiveMarker(link.trip_id, link.image_id);
          } else {
            vm.setActiveMarker(null,null);
          }
        });

      $scope.$watch(
        function(){
            return vm.map ? vm.map.getCurrentMarker() : null; },
        function(marker) {
          if (marker) {
            console.log("map changed markers", marker);
            currentTrips.setCurrentSubjectId(marker.thing_id, marker.image_id);
          }
        });
      $scope.$watch(
        function() { return currentOrigin.getLocation(); },
        function(location) {
          vm.location = location;
          vm.updateOrigin();
        });
    }

    return;
    //////////////
    function getLocation() {
      var deferred = $q.defer();

      //use current address if set
      var location = currentOrigin.getLocation();
      if (!location) {
        //try my location next
        myLocation.getCurrentLocation().then(
          function(location){
            deferred.resolve(location);
          },
          function(){
            deferred.resolve({ position: APP_CONFIG.default_position});
          });
      } else {
        deferred.resolve(location);
      }

      return deferred.promise;
    }

    function initializeMap(element, position) {
      vm.map = new Map(element, {
        center: position,
        zoom: vm.zoom || 18,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });
      displaySubjects();
    }

    function displaySubjects(){
      if (!vm.map) { return; }
      vm.map.clearMarkers();
      vm.map.clearPolylines();
      vm.map.displayOriginMarker(vm.originInfoWindow(vm.location));

      angular.forEach(vm.images, function(ti){
        displaySubject(ti);
      });
    }

    function displayTrip(trip) {
      if (!vm.map) { return; }
      vm.map.clearMarkers();
      vm.map.clearPolylines();
      vm.map.displayOriginMarker(vm.originInfoWindow(vm.location));

      console.log("displayTrip", trip);

      if (trip !== undefined && trip != null) {
        angular.forEach(trip.segments, function(s, index){
          displayStop(s);

          if (index > 0) {
            displayPath(trip.segments[index-1],trip.segments[index]);
          }
        });
      }
    }

    function displaySubject(ti) {
      var markerOptions = {
        position: {
          lng: ti.position.lng,
          lat: ti.position.lat
        },
        thing_id: ti.thing_id,
        image_id: ti.image_id
      };
      if (ti.thing_id && ti.priority===0) {
        markerOptions.title = ti.thing_name;
        markerOptions.icon = APP_CONFIG.thing_marker;
        markerOptions.content = vm.thingInfoWindow(ti);
      } else if (ti.thing_id) {
        markerOptions.title = ti.thing_name;
        markerOptions.icon = APP_CONFIG.secondary_marker;
        markerOptions.content = vm.thingInfoWindow(ti);
      } else {
        markerOptions.title = ti.image_caption;
        markerOptions.icon = APP_CONFIG.orphan_marker;
        markerOptions.content = vm.imageInfoWindow(ti);
      }
      vm.map.displayMarker(markerOptions);
    }

    function displayStop(s) {
      var markerOptions = {
        position: {
          lng: s.lng,
          lat: s.lat
        },
        trip_id: s.trip_id,
        image_id: s.image_id
      };
      markerOptions.title = "Stop " + (s.position + 1) + ': ' + s.image_caption;
      markerOptions.icon = APP_CONFIG.secondary_marker;
      markerOptions.content = vm.imageInfoWindow(s);

      vm.map.displayMarker(markerOptions);
    }

    function displayPath(start, end) {
      var path = [{lng: start.lng, lat: start.lat}, {lng: end.lng, lat: end.lat}];
      vm.map.displayPolyline(path);
    }
  }

  CurrentTripsMapController.prototype.updateOrigin = function() {
    if (this.map && this.location) {
      this.map.center({
        center: this.location.position
      });
      this.map.displayOriginMarker(this.originInfoWindow(this.location));
    }
  }

  CurrentTripsMapController.prototype.setActiveMarker = function(trip_id, image_id) {
    if (!this.map) {
      return;
    } else if (!trip_id && !image_id) {
      var currentMarker = this.map.getCurrentMarker();
      if (currentMarker == null || currentMarker.title!=='origin') {
        this.map.setActiveMarker(null);
      }
    } else {
      var markers=this.map.getMarkers();
      for (var i=0; i<markers.length; i++) {
        var marker=markers[i];
        if (marker.trip_id === trip_id && marker.image_id === image_id) {
            this.map.setActiveMarker(marker);
            break;
        }
      }
    }
  }

  CurrentTripsMapController.prototype.originInfoWindow = function(location) {
    console.log("originInfo", location);
    var full_address = location ? location.formatted_address : "";
    var lng = location && location.position ? location.position.lng : "";
    var lat = location && location.position ? location.position.lat : "";
    var html = [
      "<div class='origin'>",
        "<div class='full_address'>"+ full_address + "</div>",
        "<div class='position'>",
          "lng: <span class='lng'>"+ lng +"</span>",
          "lat: <span class='lat'>"+ lat +"</span>",
        "</div>",
      "</div>",
    ].join("\n");

    return html;
  }

  CurrentTripsMapController.prototype.thingInfoWindow = function(ti) {
    console.log("thingInfo", ti);
    var html ="<div class='thing-marker-info'><div>";
      html += "<span class='id ti_id'>"+ ti.id+"</span>";
      html += "<span class='id thing_id'>"+ ti.thing_id+"</span>";
      html += "<span class='id image_id'>"+ ti.image_id+"</span>";
      html += "<span class='thing-name'>"+ ti.thing_name + "</span>";
      if (ti.image_caption) {
        html += "<span class='image-caption'> ("+ ti.image_caption + ")</span>";
      }
      if (ti.distance) {
        html += "<span class='distance'> ("+ Number(ti.distance).toFixed(1) +" mi)</span>";
      }
      html += "</div><img src='"+ ti.image_content_url+"?width=200'>";
      html += "</div>";
    return html;
  }

  CurrentTripsMapController.prototype.imageInfoWindow = function(ti) {
    console.log("imageInfo", ti);
    var html ="<div class='image-marker-info'><div>";
      html += "<span class='id image_id'>"+ ti.image_id+"</span>";
      if (ti.image_caption) {
        html += "<span class='image-caption'>"+ ti.image_caption + "</span>";
      }
      if (ti.distance) {
        html += "<span class='distance'> ("+ Number(ti.distance).toFixed(1) +" mi)</span>";
      }
      html += "</div><img src='"+ ti.image_content_url+"?width=200'>";
      html += "</div>";
    return html;
  }


})();
