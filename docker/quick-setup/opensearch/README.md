# OpenSearch

Here is a nerdctl compose to run APIM with OpenSearch.

---
> For more information, please read :
> https://documentation.gravitee.io/apim/getting-started/configuration/repositories/elasticsearch
---

## How to run ?

`APIM_VERSION={APIM_VERSION} nerdctl compose up -d ` 

To be sure to fetch last version of images, you can do
`export APIM_VERSION={APIM_VERSION} && nerdctl compose down -v && nerdctl compose pull && nerdctl compose up`
