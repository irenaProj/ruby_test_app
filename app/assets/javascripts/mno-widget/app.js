var mnoAppModule = angular.module('mnoApp', []);

mnoAppModule.controller('mnoController', ['$scope', '$http', function($scope, $http) {
  var authData = "NzJkYjk5ZDAtMDVkYy0wMTMzLWNlZmUtMjIwMDBhOTM4NjJiOl9jSU9waW1Jb0RpM1JJdmlXdGVPVEE=";
  var config = {
    'params': {
      'engine': 'hr/employees_list',
      'metadata': '[organization_ids][]=["org-fbte"]'
      }
  };

  $scope.employeeListData = {};
  
  $http.defaults.headers.common['Authorization'] = 'Basic ' + authData;
  
  
  $http.get('https://api-impac-uat.maestrano.io/api/v1/get_widget', config).
  success(function(data, status, headers, config){
      console.log("Yey!");
      $scope.employeeListData = data;
    }).
    error(function(data, status, headers, config) {
      console.log(config);
      
      console.log(status);
    });
}]);