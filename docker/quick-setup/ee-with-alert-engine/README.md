# Enterprise Edition with Alert Engine

Here is a nerdctl compose to run APIM Enterprise Edition with Alert Engine

---
> For more information, please read :
> https://documentation.gravitee.io/apim/getting-started/configuration/notifications#configure-alerts
---

## How to run ?

⚠️ You need a license file to be able to run Enterprise Edition of APIM. Do not forget to add your license file into `./.license`.

`APIM_VERSION={APIM_VERSION} nerdctl compose up -d ` 

To be sure to fetch last version of images, you can do
`export APIM_VERSION={APIM_VERSION} && nerdctl compose down -v && nerdctl compose pull && nerdctl compose up`

