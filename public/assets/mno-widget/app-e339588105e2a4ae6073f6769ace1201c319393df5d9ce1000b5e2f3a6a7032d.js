var mnoAppModule = angular.module('mnoApp', ['leaflet-directive']);

mnoAppModule.controller('locationsController', ['$scope', 'employeeLocationsInitializer', function($scope, employeeLocationsInitializer) {
  $scope.employeeLocationsData = employeeLocationsInitializer;
}]);

mnoAppModule.controller("MarkersClusteringController1", [ "$scope", 'employeeLocationsInitializer', function($scope, employeeLocationsInitializer) {
    $scope.employeeLocationsData1 = employeeLocationsInitializer;
    angular.extend($scope, $scope.employeeLocationsData1);
}]);

mnoAppModule.controller("MarkersClusteringController2", [ "$scope", 'invoicesDataInitializer', function($scope, invoicesDataInitializer) {
    $scope.invoicesData = invoicesDataInitializer;
    angular.extend($scope, $scope.invoicesData);
}]);
