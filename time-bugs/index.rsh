'reach 0.1';

const Params = {
  amount: UInt,
  start: UInt,
  duration: UInt,
};

export const main = Reach.App(() => {
  const Creator = Participant('Creator', {
    getParams: Fun([], Object({...Params})),
    deployed: Fun([], Null),
  });
  
  const Api = API({
    release: Fun([], UInt),
  });

  init();

  // The first one to publish deploys the contract
  Creator.only(() => {
    const { amount, start, duration } = declassify(interact.getParams());
    assume(duration > 0 && amount > 0 && start >= 0);
    assume(start <= UInt.max - duration);
  });

  Creator.publish(amount, start, duration);
  commit();

  Creator.pay(amount);

  Creator.only(() => interact.deployed());

  const [ released ] = parallelReduce([ 0 ])
    .define(() => {
      const vested = () => {
        const curTime = thisConsensusTime();
        const totalAmount = balance() + released;

        if (curTime < start) {
          return 0;
        } else if (curTime >= start + duration) {
          return totalAmount;
        } else {
          return totalAmount * (curTime - start) / duration;
        }
      }

      const releasable = () => vested() - released;
    })
    .invariant(released >= 0 && releasable() >= 0)
    .while(balance() > 0)
    .api(Api.release, (callback) => {
      const toRelease = releasable();
      transfer(toRelease).to(Creator);
      callback(toRelease);
      return [ released + toRelease ];
    });
      
  commit();
  exit();
});
