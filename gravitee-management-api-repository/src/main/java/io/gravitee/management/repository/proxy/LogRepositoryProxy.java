/**
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
package io.gravitee.management.repository.proxy;

import io.gravitee.repository.analytics.AnalyticsException;
import io.gravitee.repository.analytics.query.tabular.TabularQuery;
import io.gravitee.repository.analytics.query.tabular.TabularResponse;
import io.gravitee.repository.log.api.LogRepository;
import io.gravitee.repository.log.model.Request;
import org.springframework.stereotype.Component;

/**
 * @author David BRASSELY (david.brassely at graviteesource.com)
 * @author GraviteeSource Team
 */
@Component
public class LogRepositoryProxy extends AbstractProxy<LogRepository> implements LogRepository {

    @Override
    public TabularResponse query(TabularQuery query) throws AnalyticsException {
        return target.query(query);
    }

    @Override
    public Request findById(String requestId) throws AnalyticsException {
        return target.findById(requestId);
    }
}
