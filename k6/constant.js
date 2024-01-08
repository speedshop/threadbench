import http from 'k6/http';

export const options = {
  discardResponseBodies: true,

  scenarios: {
    contacts: {
      executor: 'constant-arrival-rate',

      // Iterations per `timeUnit`
      rate: __ENV.REQ_PER_SEC || 4,

      // Start `startRate` iterations per timeUnit
      timeUnit: '1s',

      // Pre-allocate necessary VUs.
      preAllocatedVUs: 10,

      duration: '30s'
    },
  },
};

export default function() {
  http.get('http://localhost:9292');
}
