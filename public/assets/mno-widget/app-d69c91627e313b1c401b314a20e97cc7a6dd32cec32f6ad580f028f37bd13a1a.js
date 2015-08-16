var mnoAppModule = angular.module('mnoApp', ['leaflet-directive']);

mnoAppModule.controller("EmployeeLocationWidgetController", [ "$scope", 'employeeLocationsInitializer', function($scope, employeeLocationsInitializer) {
    $scope.employeeLocationsData = employeeLocationsInitializer;
    angular.extend($scope, $scope.employeeLocationsData);
}]);

mnoAppModule.controller("SalesFlowWidgetController", [ "$scope", 'invoicesDataInitializer', function($scope, invoicesDataInitializer) {
    $scope.invoicesData = invoicesDataInitializer;
    angular.extend($scope, $scope.invoicesData);
}]);
