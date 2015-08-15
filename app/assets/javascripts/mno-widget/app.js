var mnoAppModule = angular.module('mnoApp', []);

mnoAppModule.controller('mnoController', ['$scope', function($scope) {

}]);

mnoAppModule.controller('locationsController', ['$scope', 'locationsInitializer', function($scope, locationsInitializer) {
  $scope.locationsData = locationsInitializer;
}]);
