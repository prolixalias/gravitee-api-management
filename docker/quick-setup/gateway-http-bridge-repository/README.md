# Gateway with Bridge HTTP

Here is a nerdctl compose to run APIM with two gateways:
 - One as a **Bridge Server.** It can make calls to the database and expose HTTP endpoints to be able to call the database.
 - One as a **Bridge Client.** It calls the Gateway Bridge Server through HTTP to fetch data.

You can classically call your apis through your gateway, for example: `http://localhost:8082/myapi`.

To test the **Bridge Server**, you can call, for example, `http://localhost:18092/_bridge/apis` to list all the apis directly from database.

---
> For more information, please read this doc: https://documentation.gravitee.io/apim/getting-started/hybrid-deployment
---

## How to run ?

⚠️ You need a license file to be able to run Enterprise Edition of APIM. Do not forget to add your license file into `./.license`.

`APIM_VERSION={APIM_VERSION} nerdctl compose up -d ` 

To be sure to fetch last version of images, you can do
`export APIM_VERSION={APIM_VERSION} && nerdctl compose down -v && nerdctl compose pull && nerdctl compose up`