import { defineConfig } from 'vite'
import { fileURLToPath } from 'url'
import { dirname, resolve } from 'path'


const __dirname = dirname(fileURLToPath(import.meta.url))

export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false
      }
    }
  },
  css: {
    postcss: './postcss.config.js',
  },
  build: {
    rollupOptions: {
      input: {
        main:                  resolve(__dirname, 'index.html'),
        //pagesIndex:            resolve(__dirname, 'pages/index.html'),
        home:                  resolve(__dirname, 'pages/home.html'),
        dashboard:             resolve(__dirname, 'pages/dashboard.html'),
        inventory:             resolve(__dirname, 'pages/inventory.html'),
        transactions:          resolve(__dirname, 'pages/transactions.html'),
        history:               resolve(__dirname, 'pages/history.html'),
        analytics:             resolve(__dirname, 'pages/analytics.html'),
        catalog:               resolve(__dirname, 'pages/catalog.html'),
        cart:                  resolve(__dirname, 'pages/cart.html'),
        profile:               resolve(__dirname, 'pages/profile.html'),
        login:                 resolve(__dirname, 'pages/show-login.html'),
        signup:                resolve(__dirname, 'pages/show-signup.html'),
        requestform:           resolve(__dirname, 'pages/show-requestform.html'),
        adminItems:            resolve(__dirname, 'pages/admin-items.html'),
        adminRequests:         resolve(__dirname, 'pages/admin-requests.html'),
        adminUsers:            resolve(__dirname, 'pages/admin-users.html'),
        superadminPermissions: resolve(__dirname, 'pages/superadmin-permissions.html'),
        notifications:        resolve(__dirname, 'pages/notifications.html'),
        requestDetail:        resolve(__dirname, 'pages/request-detail.html'),
        depositView:          resolve(__dirname, 'pages/deposit-view.html'),
        error404:             resolve(__dirname, 'pages/404.html'),
        error403:             resolve(__dirname, 'pages/403.html'),
        error500:             resolve(__dirname, 'pages/500.html'),
      },
    },
  },
})