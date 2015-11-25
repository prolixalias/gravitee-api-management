/*
 * Copyright (C) 2015 The Gravitee team (http://gravitee.io)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
function DialogAddMemberController($scope, $mdDialog, application, ApplicationService, UserService, NotificationService) {
  'ngInject';

	$scope.application = application;
	$scope.user = {};
	$scope.usersFound = [];
	$scope.usersSelected = [];
	$scope.searchText = "";
	
  $scope.hide = function () {
     $mdDialog.cancel();
  };

	$scope.searchUser = function (query) {
		if (query) {
			return UserService.findLDAP(query).then(function(response) {
				return response.data;
			});
		}
	};

  $scope.selectedItemChange = function(item) {
		if (item) {
			$scope.usersFound.push(item);
			$scope.searchText = "";
		}
  }

	$scope.selectMember = function(user) {
		console.log(JSON.stringify(user));
		var idx = $scope.usersSelected.indexOf(user.id);
    if (idx > -1) {
      $scope.usersSelected.splice(idx, 1);
    }
    else {
      $scope.usersSelected.push(user.id);
    }
	};

  $scope.addMembers = function () {
		for (var i = 0; i < $scope.usersSelected.length; i++) {
			var username = $scope.usersSelected[i];
			var member = {
				"user" : username,
				"type" : "USER"
			};
			ApplicationService.addOrUpdateMember($scope.application.id, member).then(function() {
				NotificationService.show('Member ' + username + ' added');
			}).catch(function (error) {
				NotificationService.show('Error while adding member ' + username);
			  $scope.error = error;
			});
		}
		$mdDialog.hide($scope.application);
  };
}

export default DialogAddMemberController;
