"reach 0.1";

export const main = Reach.App(() => {
  const Creator = Participant("Creator", {
    deployed: Fun([], Null),
  });

  const Api = API({
    getTime: Fun([], UInt),
  });

  init();

  Creator.publish();
  Creator.only(() => interact.deployed());

  const [curTime] = parallelReduce([0])
    .invariant(curTime >= 0)
    .while(curTime < 10000)
    .api(Api.getTime, (callback) => {
      const newCurTime = thisConsensusTime();
      check(newCurTime >= 0);
 
      // Enabling this check leads to validation error.
      // Using `lastConsensusTime` instead of `thisConsensusTime` does not fix the error.
      // check(newCurTime >= curTime);

      callback(newCurTime);
      return [newCurTime];
    });

  transfer(balance()).to(Creator);
  commit();
  exit();
});
