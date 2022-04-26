import { loadStdlib } from "@reach-sh/stdlib";
import * as backend from "./build/index.main.mjs";
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(10000000);

const creatorAcc = await stdlib.newTestAccount(startingBalance);

const creatorCtc = creatorAcc.contract(backend);
const curTime = (await stdlib.getNetworkTime()).toNumber();
const params = {
  amount: 1000000,
  start: curTime + 20,
  duration: 50,
};

console.log(`Deploying contract with params: ${JSON.stringify(params)}`);

try {
  await creatorCtc.p.Creator({
    getParams: () => params,
    deployed: () => {
      throw ["done", {}];
    },
  });
} catch (e) {
  if (e[0] !== "done") throw e;
}

console.log("Starting queries...");
let total = 0;
let moment = curTime;
while (total < params.amount) {
  await stdlib.waitUntilTime(moment);
  const released = (await creatorCtc.a.release()).toNumber();
  total += released;
  console.log(`Waited until ${moment}, released ${released} (total ${total})`);
  moment += 10;
}

console.log("Queries done");