var mnoAppModule = angular.module('mnoApp', ['leaflet-directive']);

mnoAppModule.controller("EmployeeLocationWidgetController", [ "$scope", 'employeeLocationsInitializer', function($scope, employeeLocationsInitializer) {
    angular.extend($scope, employeeLocationsInitializer);
}]);

mnoAppModule.controller("SalesFlowWidgetController", [ "$scope", 'invoicesDataInitializer', function($scope, invoicesDataInitializer) {
    angular.extend($scope, invoicesDataInitializer);
}]);
