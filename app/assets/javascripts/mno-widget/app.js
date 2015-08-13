var mnoAppModule = angular.module('mnoApp', ['uiGmapgoogle-maps']);

mnoAppModule.config(function(uiGmapGoogleMapApiProvider) {
    uiGmapGoogleMapApiProvider.configure({
        key: 'AIzaSyDJlC1gSSlY7l4qla1VKCU-RhMtMBPmpr0',
        v: '3.17',
        libraries: 'weather,geometry,visualization'
    });
});

mnoAppModule.controller('mnoController', ['$scope', '$http', 'uiGmapGoogleMapApi', function($scope, $http, uiGmapGoogleMapApi) {
  var authData = "NzJkYjk5ZDAtMDVkYy0wMTMzLWNlZmUtMjIwMDBhOTM4NjJiOl9jSU9waW1Jb0RpM1JJdmlXdGVPVEE=";
  var config = {
    'params': {
      'engine': 'hr/employees_list',
      'metadata': '[organization_ids][]=["org-fbte"]'
      }
  };
  
  uiGmapGoogleMapApi.then(function(maps) {
    $scope.map = { center: { latitude: 45, longitude: -73 }, zoom: 8 };
  });

  // $scope.employeeListData = {};
  
  // $http.defaults.headers.common['Authorization'] = 'Basic ' + authData;
  
  
  // $http.get('https://api-impac-uat.maestrano.io/api/v1/get_widget', config).
  // success(function(data, status, headers, config){
  //     console.log("Yey!");
  //     $scope.employeeListData = data;
  //   }).
  //   error(function(data, status, headers, config) {
  //     console.log(config);
      
  //     console.log(status);
  //   });
}]);