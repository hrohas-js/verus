# Quick Start - Vue Integration

## ⚡ Get Started in 3 Steps

### 1️⃣ Install Dependencies
```bash
cd verus-backend
npm install
```

### 2️⃣ Start Development Servers

**Terminal 1 - Vite Dev Server:**
```bash
npm run dev
```

**Terminal 2 - Laravel Server:**
```bash
php artisan serve
```

### 3️⃣ Open Browser
Navigate to: `http://localhost:8000`

---

## 🎯 Quick Test

1. **Default View**: You'll be redirected to `/mech` (mechanic view)
2. **Add Items**: Click `+` buttons to add items to your order
3. **View Order**: Click "Смотреть заказ" at the bottom
4. **Admin Mode**: Click "Редактировать остатки" to switch to admin view
5. **Edit Stock**: In admin mode, click "Изм." to edit quantities

---

## 🛠️ Available Commands

```bash
# Development
npm run dev              # Start Vite dev server with HMR
npm run build            # Build for production
npm run preview          # Preview production build

# Type Checking
npm run type-check       # Check TypeScript types

# Linting
npm run lint             # Lint and fix code
npm run format           # Format code with Prettier
```

---

## 📂 Key Files Modified

- ✅ `package.json` - Added Vue dependencies
- ✅ `vite.config.js` - Configured Vite for Vue + Laravel
- ✅ `tsconfig.json` - TypeScript configuration
- ✅ `resources/js/` - All Vue application code
- ✅ `resources/views/app.blade.php` - Main SPA template
- ✅ `routes/web.php` - SPA routing

---

## 🔧 Troubleshooting

### Issue: Vite assets not loading
**Solution**: Make sure `npm run dev` is running

### Issue: API errors
**Solution**: Check that Laravel server is running and database is set up

### Issue: TypeScript errors
**Solution**: Run `npm run type-check` to see detailed errors

### Issue: Port already in use
**Solution**: Change port in `vite.config.js` or stop other dev servers

---

## 📚 Learn More

- [Vue 3 Documentation](https://vuejs.org/)
- [Vuetify 3 Documentation](https://vuetifyjs.com/)
- [Laravel Vite Plugin](https://laravel.com/docs/vite)
- [Pinia Documentation](https://pinia.vuejs.org/)

---

🎉 **That's it! Your Vue SPA is now integrated with Laravel!**
