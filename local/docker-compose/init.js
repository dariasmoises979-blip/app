// ============================================================================
// Script de Inicialización de MongoDB para Microservicios
// ============================================================================
// Este script se ejecuta automáticamente al crear el contenedor
// ============================================================================

// Crear base de datos de Catálogo de Productos
db = db.getSiblingDB('catalog_db');

// Crear colecciones con validación de esquema
db.createCollection('products', {
    validator: {
        $jsonSchema: {
            bsonType: 'object',
            required: ['name', 'sku', 'price', 'category'],
            properties: {
                name: {
                    bsonType: 'string',
                    description: 'Nombre del producto - requerido'
                },
                sku: {
                    bsonType: 'string',
                    description: 'SKU único - requerido'
                },
                description: {
                    bsonType: 'string'
                },
                price: {
                    bsonType: 'number',
                    minimum: 0,
                    description: 'Precio debe ser mayor o igual a 0'
                },
                category: {
                    bsonType: 'string',
                    description: 'Categoría del producto - requerido'
                },
                tags: {
                    bsonType: 'array',
                    items: {
                        bsonType: 'string'
                    }
                },
                images: {
                    bsonType: 'array',
                    items: {
                        bsonType: 'object',
                        properties: {
                            url: { bsonType: 'string' },
                            alt: { bsonType: 'string' },
                            isPrimary: { bsonType: 'bool' }
                        }
                    }
                },
                specifications: {
                    bsonType: 'object'
                },
                reviews: {
                    bsonType: 'array',
                    items: {
                        bsonType: 'object',
                        properties: {
                            userId: { bsonType: 'string' },
                            rating: { bsonType: 'number', minimum: 1, maximum: 5 },
                            comment: { bsonType: 'string' },
                            date: { bsonType: 'date' }
                        }
                    }
                },
                stock: {
                    bsonType: 'number',
                    minimum: 0
                },
                isActive: {
                    bsonType: 'bool'
                },
                createdAt: {
                    bsonType: 'date'
                },
                updatedAt: {
                    bsonType: 'date'
                }
            }
        }
    }
});

// Crear índices para productos
db.products.createIndex({ 'sku': 1 }, { unique: true });
db.products.createIndex({ 'name': 'text', 'description': 'text', 'tags': 'text' });
db.products.createIndex({ 'category': 1 });
db.products.createIndex({ 'price': 1 });
db.products.createIndex({ 'createdAt': -1 });
db.products.createIndex({ 'reviews.rating': 1 });

// Insertar productos de ejemplo
db.products.insertMany([
    {
        name: 'Smartphone Galaxy X10',
        sku: 'PHONE-001',
        description: 'Smartphone de última generación con pantalla AMOLED',
        price: 899.99,
        category: 'Smartphones',
        tags: ['electronics', 'mobile', 'android', '5g'],
        images: [
            { url: 'https://example.com/phone1.jpg', alt: 'Galaxy X10 Front', isPrimary: true },
            { url: 'https://example.com/phone2.jpg', alt: 'Galaxy X10 Back', isPrimary: false }
        ],
        specifications: {
            screen: '6.7 inches',
            ram: '8GB',
            storage: '256GB',
            battery: '5000mAh',
            camera: '108MP'
        },
        reviews: [
            { userId: 'user123', rating: 5, comment: '¡Excelente teléfono!', date: new Date('2024-01-15') },
            { userId: 'user456', rating: 4, comment: 'Muy bueno pero caro', date: new Date('2024-02-01') }
        ],
        stock: 50,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
    },
    {
        name: 'Laptop ProBook 15',
        sku: 'LAPTOP-001',
        description: 'Laptop profesional para trabajo y diseño',
        price: 1299.99,
        category: 'Computers',
        tags: ['electronics', 'laptop', 'professional', 'intel'],
        images: [
            { url: 'https://example.com/laptop1.jpg', alt: 'ProBook 15', isPrimary: true }
        ],
        specifications: {
            processor: 'Intel Core i7',
            ram: '16GB',
            storage: '512GB SSD',
            screen: '15.6 inches FHD'
        },
        reviews: [],
        stock: 25,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
    }
]);

// ============================================================================
// Base de datos de Contenido y Blog
// ============================================================================
db = db.getSiblingDB('content_db');

// Colección de artículos de blog
db.createCollection('articles', {
    validator: {
        $jsonSchema: {
            bsonType: 'object',
            required: ['title', 'slug', 'content', 'author'],
            properties: {
                title: { bsonType: 'string' },
                slug: { bsonType: 'string' },
                content: { bsonType: 'string' },
                excerpt: { bsonType: 'string' },
                author: {
                    bsonType: 'object',
                    properties: {
                        id: { bsonType: 'string' },
                        name: { bsonType: 'string' },
                        email: { bsonType: 'string' }
                    }
                },
                tags: { bsonType: 'array' },
                categories: { bsonType: 'array' },
                featuredImage: { bsonType: 'string' },
                status: { 
                    enum: ['draft', 'published', 'archived'],
                    description: 'Estado del artículo'
                },
                publishedAt: { bsonType: 'date' },
                views: { bsonType: 'number' },
                likes: { bsonType: 'number' }
            }
        }
    }
});

db.articles.createIndex({ 'slug': 1 }, { unique: true });
db.articles.createIndex({ 'title': 'text', 'content': 'text', 'tags': 'text' });
db.articles.createIndex({ 'publishedAt': -1 });
db.articles.createIndex({ 'author.id': 1 });

// Insertar artículos de ejemplo
db.articles.insertMany([
    {
        title: 'Introducción a los Microservicios',
        slug: 'introduccion-microservicios',
        content: 'Los microservicios son un patrón arquitectónico...',
        excerpt: 'Aprende los fundamentos de la arquitectura de microservicios',
        author: {
            id: 'author1',
            name: 'Juan Pérez',
            email: 'juan@example.com'
        },
        tags: ['arquitectura', 'microservicios', 'backend'],
        categories: ['Tecnología', 'Programación'],
        featuredImage: 'https://example.com/microservices.jpg',
        status: 'published',
        publishedAt: new Date('2024-03-01'),
        views: 1250,
        likes: 45,
        createdAt: new Date(),
        updatedAt: new Date()
    }
]);

// Colección de comentarios
db.createCollection('comments');
db.comments.createIndex({ 'articleId': 1 });
db.comments.createIndex({ 'userId': 1 });
db.comments.createIndex({ 'createdAt': -1 });

// ============================================================================
// Base de datos de Logs y Auditoría
// ============================================================================
db = db.getSiblingDB('logs_db');

// Colección de logs de aplicación con TTL (se eliminan después de 30 días)
db.createCollection('application_logs');
db.application_logs.createIndex({ 'timestamp': 1 }, { expireAfterSeconds: 2592000 }); // 30 días
db.application_logs.createIndex({ 'level': 1 });
db.application_logs.createIndex({ 'service': 1 });
db.application_logs.createIndex({ 'userId': 1 });

// Insertar logs de ejemplo
db.application_logs.insertMany([
    {
        timestamp: new Date(),
        level: 'info',
        service: 'user-service',
        message: 'Usuario creado exitosamente',
        userId: 'user123',
        metadata: {
            ip: '192.168.1.1',
            userAgent: 'Mozilla/5.0...'
        }
    },
    {
        timestamp: new Date(),
        level: 'error',
        service: 'payment-service',
        message: 'Error al procesar pago',
        userId: 'user456',
        error: {
            code: 'PAYMENT_FAILED',
            message: 'Tarjeta declinada'
        }
    }
]);

// Colección de auditoría (sin TTL, se mantiene indefinidamente)
db.createCollection('audit_logs');
db.audit_logs.createIndex({ 'timestamp': -1 });
db.audit_logs.createIndex({ 'userId': 1 });
db.audit_logs.createIndex({ 'action': 1 });
db.audit_logs.createIndex({ 'entity': 1 });

db.audit_logs.insertMany([
    {
        timestamp: new Date(),
        userId: 'admin1',
        action: 'CREATE',
        entity: 'user',
        entityId: 'user789',
        changes: {
            email: 'newuser@example.com',
            role: 'customer'
        },
        ip: '192.168.1.1',
        userAgent: 'PostmanRuntime/7.29.2'
    }
]);

// ============================================================================
// Base de datos de Sesiones y Cache
// ============================================================================
db = db.getSiblingDB('sessions_db');

// Colección de sesiones con TTL (expiran después de 24 horas)
db.createCollection('sessions');
db.sessions.createIndex({ 'lastActivity': 1 }, { expireAfterSeconds: 86400 }); // 24 horas
db.sessions.createIndex({ 'sessionId': 1 }, { unique: true });
db.sessions.createIndex({ 'userId': 1 });

// Colección de cache genérico con TTL
db.createCollection('cache');
db.cache.createIndex({ 'expiresAt': 1 }, { expireAfterSeconds: 0 });
db.cache.createIndex({ 'key': 1 }, { unique: true });

// ============================================================================
// Base de datos de Búsqueda y Recomendaciones
// ============================================================================
db = db.getSiblingDB('search_db');

// Colección de histórico de búsquedas
db.createCollection('search_history');
db.search_history.createIndex({ 'userId': 1 });
db.search_history.createIndex({ 'query': 1 });
db.search_history.createIndex({ 'timestamp': -1 });
db.search_history.createIndex({ 'timestamp': 1 }, { expireAfterSeconds: 7776000 }); // 90 días

// Colección de términos de búsqueda populares
db.createCollection('trending_searches');
db.trending_searches.createIndex({ 'count': -1 });
db.trending_searches.createIndex({ 'lastSearched': -1 });

db.trending_searches.insertMany([
    { term: 'smartphone', count: 1500, lastSearched: new Date() },
    { term: 'laptop', count: 980, lastSearched: new Date() },
    { term: 'headphones', count: 750, lastSearched: new Date() }
]);

// Colección de recomendaciones personalizadas
db.createCollection('recommendations');
db.recommendations.createIndex({ 'userId': 1 });
db.recommendations.createIndex({ 'productId': 1 });
db.recommendations.createIndex({ 'score': -1 });

// ============================================================================
// Funciones útiles
// ============================================================================

// Función para obtener estadísticas de productos
db = db.getSiblingDB('catalog_db');

// Crear vista agregada de productos más vendidos
db.createView('popular_products', 'products', [
    {
        $match: { isActive: true }
    },
    {
        $project: {
            name: 1,
            sku: 1,
            price: 1,
            category: 1,
            averageRating: { $avg: '$reviews.rating' },
            reviewCount: { $size: { $ifNull: ['$reviews', []] } }
        }
    },
    {
        $sort: { reviewCount: -1, averageRating: -1 }
    }
]);

// ============================================================================
// Datos de configuración del sistema
// ============================================================================
db = db.getSiblingDB('config_db');

db.createCollection('settings');
db.settings.insertMany([
    {
        key: 'email_notifications',
        value: true,
        description: 'Activar notificaciones por email',
        updatedAt: new Date()
    },
    {
        key: 'maintenance_mode',
        value: false,
        description: 'Modo de mantenimiento del sistema',
        updatedAt: new Date()
    },
    {
        key: 'default_currency',
        value: 'EUR',
        description: 'Moneda por defecto',
        updatedAt: new Date()
    },
    {
        key: 'tax_rate',
        value: 0.21,
        description: 'Tasa de impuesto (IVA)',
        updatedAt: new Date()
    }
]);

db.settings.createIndex({ 'key': 1 }, { unique: true });

// ============================================================================
// Crear usuario de aplicación con permisos limitados
// ============================================================================
db = db.getSiblingDB('admin');
db.createUser({
    user: 'app_user',
    pwd: 'app_secure_pass',
    roles: [
        { role: 'readWrite', db: 'catalog_db' },
        { role: 'readWrite', db: 'content_db' },
        { role: 'readWrite', db: 'logs_db' },
        { role: 'readWrite', db: 'sessions_db' },
        { role: 'readWrite', db: 'search_db' },
        { role: 'read', db: 'config_db' }
    ]
});

print('========================================');
print('MongoDB inicializado correctamente');
print('Bases de datos creadas:');
print('  - catalog_db: Catálogo de productos');
print('  - content_db: Blog y contenido');
print('  - logs_db: Logs de aplicación');
print('  - sessions_db: Sesiones y cache');
print('  - search_db: Búsquedas y recomendaciones');
print('  - config_db: Configuración del sistema');
print('========================================');