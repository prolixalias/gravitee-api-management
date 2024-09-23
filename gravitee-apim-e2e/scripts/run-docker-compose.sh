#!/bin/bash
# Copyright (C) 2015 The Gravitee team (http://gravitee.io)
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#         http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


computeCypressEnvVariables() {
  export COMMIT_INFO_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  export COMMIT_INFO_MESSAGE=$(git show -s --pretty=%B)
  export COMMIT_INFO_EMAIL=$(git show -s --pretty=%ae)
  export COMMIT_INFO_AUTHOR=$(git show -s --pretty=%an)
  export COMMIT_INFO_SHA=$(git show -s --pretty=%H)
  export COMMIT_INFO_TIMESTAMP=$(git show -s --pretty=%ct)
  export COMMIT_INFO_REMOTE=$(git config --get remote.origin.url)
}

clean() {
#  For each nerdctl compose service stop & remove containers & volumes
  nerdctl compose -f ./docker/common/nerdctl compose-base.yml -f ./docker/common/nerdctl compose-mongo.yml -f ./docker/common/nerdctl compose-jdbc.yml -f ./docker/common/nerdctl compose-apis.yml -f ./docker/common/nerdctl compose-wiremock.yml -f ./docker/common/nerdctl compose-uis.yml -f ./docker/ui-tests/nerdctl compose-ui-tests.yml -f ./docker/api-tests/nerdctl compose-api-tests.yml --project-directory $PWD rm --force --stop -v 2>/dev/null
}

if [ -n "$1" ] && [ "$1" = "clean" ]; then
  clean
  exit 0
fi

if [ -n "$1" ] && [ -n "$2" ]; then
  clean
  # Create a tmp directory with video and screenshot folders for cypress
  mkdir -p .tmp/screenshots
  mkdir -p .tmp/videos
  chmod -R 777 .tmp
  mkdir -p .logs
  chmod -R 777 .logs

  mode="$1"
  databaseType="$2"

  jdbcDriver="postgresql-42.4.0.jar"
  jdbcDest="./docker/common/tmp/jdbc-driver/$jdbcDriver"

  if [ "$databaseType" = "jdbc" ] && [ ! -f "$jdbcDest" ]; then
    curl https://jdbc.postgresql.org/download/$jdbcDriver --create-dirs -o $jdbcDest
  fi

  if [ "$mode" = "only-apim" ]; then
    DB_PROVIDER=$databaseType nerdctl compose -f ./docker/common/nerdctl compose-base.yml -f ./docker/common/nerdctl compose-$databaseType.yml -f ./docker/common/nerdctl compose-apis.yml -f ./docker/common/nerdctl compose-wiremock.yml -f ./docker/common/nerdctl compose-uis.yml --project-directory $PWD up $3
  elif [ "$mode" = "api-test" ]; then
    if [ "$databaseType" = "bridge" ]; then
      DB_PROVIDER=$databaseType nerdctl compose -f ./docker/common/nerdctl compose-base.yml -f ./docker/common/nerdctl compose-mongo.yml -f ./docker/common/nerdctl compose-bridge.yml -f ./docker/common/nerdctl compose-wiremock.yml -f ./docker/api-tests/nerdctl compose-api-tests.yml --project-directory $PWD up --abort-on-container-exit --exit-code-from jest-e2e
    else
      DB_PROVIDER=$databaseType nerdctl compose -f ./docker/common/nerdctl compose-base.yml -f ./docker/common/nerdctl compose-$databaseType.yml -f ./docker/common/nerdctl compose-apis.yml -f ./docker/common/nerdctl compose-wiremock.yml -f ./docker/api-tests/nerdctl compose-api-tests.yml --project-directory $PWD up --abort-on-container-exit --exit-code-from jest-e2e
    fi
  elif [ "$mode" = "ui-test" ]; then
    computeCypressEnvVariables
    DB_PROVIDER=$databaseType nerdctl compose -f ./docker/common/nerdctl compose-base.yml -f ./docker/common/nerdctl compose-$databaseType.yml -f ./docker/common/nerdctl compose-apis.yml -f ./docker/common/nerdctl compose-wiremock.yml -f ./docker/common/nerdctl compose-uis.yml -f ./docker/ui-tests/nerdctl compose-ui-tests.yml --project-directory $PWD up --no-build --abort-on-container-exit --exit-code-from cypress
  fi
  # Save exit code of nerdctl compose
  status=$?

  # Extract logs from containers if it exists
  docker logs gravitee-apim-e2e-cypress-1 > ./.logs/cypress.log || true
  docker logs gravitee-apim-e2e-gateway > ./.logs/gateway.log || true
  docker logs gravitee-apim-e2e-management_api > ./.logs/management_api.log || true
  docker logs gravitee-apim-e2e-management_ui > ./.logs/management_ui.log || true
  docker logs gravitee-apim-e2e-portal_ui > ./.logs/portal_ui.log || true
  docker logs gravitee-apim-e2e-nginx > ./.logs/nginx.log || true
  docker logs gravitee-apim-e2e-wiremock > ./.logs/wiremock.log || true
  docker logs gravitee-apim-e2e-elasticsearch > ./.logs/elasticsearch.log || true
  docker logs gravitee-apim-e2e-jest-e2e-1 > ./.logs/jest.log || true
  # TODO: Need to add DB logs

  # Use exit code of nerdctl compose
  exit $status

else
  echo "Usage: $0 [clean|only-apim|api-test|ui-test] [mongo|jdbc|bridge]"
fi
