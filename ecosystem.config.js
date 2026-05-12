// /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn/ecosystem.config.js
module.exports = {
  apps: [
    {
      /* ──────────────── process meta ──────────────── */
      name : 'aoe2dewarwagers-web',
      cwd  : '/mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn',

      // Run the server produced by `next build`
      script : 'node_modules/.bin/next',
      args   : 'start -H 127.0.0.1 -p 4000',

      /* ──────────────── environment ──────────────── */
      env: {
        NODE_ENV: 'production',

        /* Keep browser API calls same-origin; proxy server-side to api-prodn */
        NEXT_PUBLIC_API_BASE_URL: '.',
        AOE2_BACKEND_UPSTREAM : 'http://127.0.0.1:4400',
        NEXT_PUBLIC_CHAIN_ID    : '11865'
      },

      /* ──────────────── PM2 niceties ──────────────── */
      instances    : 1,      // keep it single-instance; Nginx handles load-balancing
      exec_mode    : 'fork',
      restart_delay: 500
    }
  ]
};
