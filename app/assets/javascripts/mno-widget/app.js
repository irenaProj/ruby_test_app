var mnoAppModule = angular.module('mnoApp', ['uiGmapgoogle-maps']);

mnoAppModule.config(function(uiGmapGoogleMapApiProvider) {
    uiGmapGoogleMapApiProvider.configure({
        key: 'AIzaSyDJlC1gSSlY7l4qla1VKCU-RhMtMBPmpr0',
        v: '3.17',
        libraries: 'weather,geometry,visualization'
    });
});


mnoAppModule.controller('mnoController', ['$scope', '$http', 'uiGmapGoogleMapApi', function($scope, $http, uiGmapGoogleMapApi) {
  uiGmapGoogleMapApi.then(function(maps) {
    $scope.map = { center: { latitude: 45, longitude: -73 }, zoom: 8 };
  });
}]);

mnoAppModule.controller('otherController', ['$scope', 'dataInitializer', function($scope, dataInitializer) {
  $scope.employeeListData = dataInitializer;
}]);
