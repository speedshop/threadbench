import http from 'k6/http';

export const options = {
  discardResponseBodies: true,

  scenarios: {
    contacts: {
      executor: 'constant-arrival-rate',

      // Iterations per `timeUnit`
      rate: 3,

      // Start `startRate` iterations per timeUnit
      timeUnit: '1s',

      // Pre-allocate necessary VUs.
      preAllocatedVUs: 5,

      duration: '60s'
    },
  },
  thresholds: {
    http_req_waiting: [
      {
        threshold: 'avg<375', // response time must be less than 375 ms (50% degraded or 125ms slower)
        abortOnFail: true,
      },
      {
        threshold: 'p(99)<1000', // p99 must be less than 1000 ms (~4x slower)
        abortOnFail: true,
      },
    ]
  },
};

export default function() {
  http.get('http://localhost:9292');
}
