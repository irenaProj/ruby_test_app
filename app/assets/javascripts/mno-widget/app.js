var mnoAppModule = angular.module('mnoApp', ['uiGmapgoogle-maps']);

mnoAppModule.config(function(uiGmapGoogleMapApiProvider) {
    uiGmapGoogleMapApiProvider.configure({
        key: 'AIzaSyDJlC1gSSlY7l4qla1VKCU-RhMtMBPmpr0',
        v: '3.17',
        libraries: 'weather,geometry,visualization'
    });
});

mnoAppModule.controller('mnoController', ['$scope', 'uiGmapGoogleMapApi', function($scope, uiGmapGoogleMapApi) {
  // var req = {
  //   method: 'GET',
  //   url: 'https://api-impac-uat.maestrano.io/api/v1/get_widget?engine=hr/employees_list&metadata[organization_ids][]=org-fbte',
  //   headers: {
  //   'Authorization': 'Basic NzJkYjk5ZDAtMDVkYy0wMTMzLWNlZmUtMjIwMDBhOTM4NjJiOl9jSU9waW1Jb0RpM1JJdmlXdGVPVEE='
  //   }
  // }

  // $http(req).then(
  //   function(response) {
  //     $scope.employeeListData = response.data;
  //   },
  //   function(data) {
      
  //   }
  // );
   
  uiGmapGoogleMapApi.then(function(maps) {
    $scope.map = { center: { latitude: 45, longitude: -73 }, zoom: 8 };
  });
}]);