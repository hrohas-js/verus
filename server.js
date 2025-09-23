const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const PORT = 8000;

// Middleware
app.use(cors());
app.use(express.json());

// Инициализация SQLite базы данных
const dbPath = path.join(__dirname, 'database', 'database.sqlite');
const db = new sqlite3.Database(dbPath);

// Создание таблицы equipment если её нет
db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS equipment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title VARCHAR(255) NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        image VARCHAR(255),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Вставка тестовых данных
    db.run(`INSERT OR IGNORE INTO equipment (id, title, quantity, image) VALUES
        (1, 'Монитор Samsung 24"', 15, 'samsung-monitor.jpg'),
        (2, 'Клавиатура Logitech', 8, 'logitech-keyboard.jpg'),
        (3, 'Мышь Razer', 12, 'razer-mouse.jpg'),
        (4, 'Веб-камера HD', 5, 'webcam.jpg')`);
});

// API Routes

// Health Check
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Verus Warehouse API is running',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Получить все оборудование
app.get('/api/equipment', (req, res) => {
    db.all('SELECT * FROM equipment ORDER BY id ASC', (err, rows) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({
            data: rows,
            message: 'Equipment retrieved successfully'
        });
    });
});

// Получить конкретное оборудование
app.get('/api/equipment/:id', (req, res) => {
    const { id } = req.params;
    db.get('SELECT * FROM equipment WHERE id = ?', [id], (err, row) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        if (!row) {
            return res.status(404).json({ message: 'Equipment not found' });
        }
        res.json({
            data: row,
            message: 'Equipment retrieved successfully'
        });
    });
});

// Добавить новое оборудование
app.post('/api/equipment', (req, res) => {
    const { title, quantity, image } = req.body;

    // Валидация
    if (!title || quantity === undefined) {
        return res.status(400).json({
            message: 'Validation failed',
            errors: {
                title: title ? null : 'Title is required',
                quantity: quantity !== undefined ? null : 'Quantity is required'
            }
        });
    }

    const stmt = db.prepare(`INSERT INTO equipment (title, quantity, image, created_at, updated_at)
                           VALUES (?, ?, ?, datetime('now'), datetime('now'))`);

    stmt.run([title, quantity, image || null], function(err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        // Получаем созданную запись
        db.get('SELECT * FROM equipment WHERE id = ?', [this.lastID], (err, row) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            res.status(201).json({
                data: row,
                message: 'Equipment created successfully'
            });
        });
    });
    stmt.finalize();
});

// Обновить оборудование
app.put('/api/equipment/:id', (req, res) => {
    const { id } = req.params;
    const { title, quantity, image } = req.body;

    if (!title || quantity === undefined) {
        return res.status(400).json({
            message: 'Validation failed',
            errors: {
                title: title ? null : 'Title is required',
                quantity: quantity !== undefined ? null : 'Quantity is required'
            }
        });
    }

    const stmt = db.prepare(`UPDATE equipment
                           SET title = ?, quantity = ?, image = ?, updated_at = datetime('now')
                           WHERE id = ?`);

    stmt.run([title, quantity, image || null, id], function(err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        if (this.changes === 0) {
            return res.status(404).json({ message: 'Equipment not found' });
        }

        // Получаем обновленную запись
        db.get('SELECT * FROM equipment WHERE id = ?', [id], (err, row) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            res.json({
                data: row,
                message: 'Equipment updated successfully'
            });
        });
    });
    stmt.finalize();
});

// Обновить количество
app.patch('/api/equipment/:id/quantity', (req, res) => {
    const { id } = req.params;
    const { quantity } = req.body;

    if (quantity === undefined) {
        return res.status(400).json({
            message: 'Validation failed',
            errors: { quantity: 'Quantity is required' }
        });
    }

    const stmt = db.prepare(`UPDATE equipment
                           SET quantity = ?, updated_at = datetime('now')
                           WHERE id = ?`);

    stmt.run([quantity, id], function(err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        if (this.changes === 0) {
            return res.status(404).json({ message: 'Equipment not found' });
        }

        // Получаем обновленную запись
        db.get('SELECT * FROM equipment WHERE id = ?', [id], (err, row) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            res.json({
                data: row,
                message: 'Equipment quantity updated successfully'
            });
        });
    });
    stmt.finalize();
});

// Удалить оборудование
app.delete('/api/equipment/:id', (req, res) => {
    const { id } = req.params;

    const stmt = db.prepare('DELETE FROM equipment WHERE id = ?');
    stmt.run([id], function(err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        if (this.changes === 0) {
            return res.status(404).json({ message: 'Equipment not found' });
        }

        res.json({
            message: 'Equipment deleted successfully'
        });
    });
    stmt.finalize();
});

// Обработка 404
app.use((req, res) => {
    res.status(404).json({
        message: 'Route not found',
        available_routes: [
            'GET /api/health',
            'GET /api/equipment',
            'POST /api/equipment',
            'GET /api/equipment/:id',
            'PUT /api/equipment/:id',
            'PATCH /api/equipment/:id/quantity',
            'DELETE /api/equipment/:id'
        ]
    });
});

// Запуск сервера
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Verus Warehouse API запущен на http://localhost:${PORT}`);
    console.log(`📍 API Base URL: http://localhost:${PORT}/api`);
    console.log(`🏥 Health Check: http://localhost:${PORT}/api/health`);
    console.log(`📊 Equipment API: http://localhost:${PORT}/api/equipment`);
    console.log(`\n✅ Сервер готов к работе!`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Останавливаем сервер...');
    db.close((err) => {
        if (err) {
            console.error(err.message);
        } else {
            console.log('✅ База данных закрыта.');
        }
        process.exit(0);
    });
});
